# One OpenTelemetry span per test, under a session span parented on
# TRACEPARENT, exported once as OTLP/HTTP protobuf. It uses only the standard
# library because it loads outside the project's bundle and must never
# conflict with the project's own gems.
require "net/http"
require "securerandom"
require "timeout"

module DaggerMinitestOtel
  module_function

  def varint(n)
    out = +""
    loop do
      byte = n & 0x7f
      n >>= 7
      out << (n.zero? ? byte : byte | 0x80).chr
      return out.b if n.zero?
    end
  end

  # Field numbers follow opentelemetry/proto/trace/v1/trace.proto.
  def field(number, value) = varint((number << 3) | 2) + varint(value.b.bytesize) + value.b
  def text(number, value) = field(number, value.to_s.encode("UTF-8", invalid: :replace, undef: :replace).scrub)
  def fixed64(number, value) = varint((number << 3) | 1) + [value].pack("Q<")
  def enum(number, value) = varint(number << 3) + varint(value)
  def now = Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond)

  def attributes(number, pairs)
    pairs.map { |key, value| field(number, text(1, key) + field(2, text(1, value))) }.join.b
  end

  def span(trace_id, id, parent, name, start, finish, attrs, error = nil, events = "")
    status = error ? text(2, error) + enum(3, 2) : enum(3, 1)
    field(1, trace_id) + field(2, id) + (parent ? field(4, parent) : "".b) + text(5, name) +
      enum(6, 1) + fixed64(7, start) + fixed64(8, finish) + attributes(9, attrs) + events + field(15, status)
  end

  # Only the class: Dagger does not mask secrets in exported spans, so failure
  # messages and backtraces stay in the test output, where it does.
  def exception(error, time)
    field(11, fixed64(1, time) + text(2, "exception") + attributes(3, { "exception.type" => error.class.name }))
  end

  class Reporter < Minitest::AbstractReporter
    def initialize(endpoint, traceparent)
      super()
      _, trace, parent, = traceparent.to_s.split("-")
      @endpoint = endpoint
      @trace_id = [trace || SecureRandom.hex(16)].pack("H*")
      @parent = parent && [parent].pack("H*")
      @session = SecureRandom.bytes(8)
      @spans = []
      @failed = false
    end

    def start = @start = DaggerMinitestOtel.now

    def record(result)
      finish = DaggerMinitestOtel.now
      outcome = if result.skipped? then "skipped" elsif result.passed? then "pass" else "fail" end
      @failed ||= outcome == "fail"
      attrs = { "test.case.name" => "#{result.klass}##{result.name}", "code.namespace" => result.klass,
                "code.function" => result.name, "test.case.result.status" => outcome }
      attrs["test.case.result.reason"] = result.failure.message if outcome == "skipped"
      errors = outcome == "fail" ? result.failures.map { |f| f.respond_to?(:error) ? f.error : f } : []
      events = errors.map { |error| DaggerMinitestOtel.exception(error, finish) }.join.b
      @spans << DaggerMinitestOtel.span(@trace_id, SecureRandom.bytes(8), @session, attrs["test.case.name"],
                                        finish - (result.time * 1e9).to_i, finish, attrs,
                                        outcome == "fail" ? "test failed" : nil, events)
    end

    def report
      status = @failed ? "failure" : "success"
      session = DaggerMinitestOtel.span(@trace_id, @session, @parent, "minitest", @start, DaggerMinitestOtel.now,
                                        { "test.suite.name" => "minitest", "test.suite.run.status" => status },
                                        @failed ? "test session failed" : nil)
      scope = DaggerMinitestOtel.field(1, DaggerMinitestOtel.text(1, "dagger_minitest_otel")) +
              ([session] + @spans).map { |s| DaggerMinitestOtel.field(2, s) }.join.b
      resource = DaggerMinitestOtel.field(1, DaggerMinitestOtel.attributes(1, { "service.name" => "minitest" }))
      body = DaggerMinitestOtel.field(1, resource + DaggerMinitestOtel.field(2, scope))
      uri = URI(@endpoint)
      Timeout.timeout(5) do
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                            open_timeout: 2, read_timeout: 3, write_timeout: 3) do |http|
          http.post(uri.request_uri, body, "Content-Type" => "application/x-protobuf").value
        end
      end
    rescue StandardError => e
      warn "\ndagger_minitest_otel: spans not exported: #{e.class}: #{e.message}"
    end
  end
end

module Minitest
  def self.plugin_dagger_otel_init(_options)
    base = ENV["OTEL_EXPORTER_OTLP_ENDPOINT"]
    endpoint = ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"] || (base && "#{base.chomp("/")}/v1/traces")
    reporter << DaggerMinitestOtel::Reporter.new(endpoint, ENV["TRACEPARENT"]) if endpoint&.start_with?("http")
  end
end
