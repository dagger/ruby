# One OpenTelemetry span per test, under a session span parented on
# TRACEPARENT, exported once as OTLP/HTTP protobuf. It uses only the standard
# library because it loads outside the project's bundle and must never
# conflict with the project's own gems.
require "net/http"
require "securerandom"
require "timeout"

module DaggerTestOtel
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

  def endpoint
    base = ENV["OTEL_EXPORTER_OTLP_ENDPOINT"]
    url = ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"] || (base && "#{base.chomp("/")}/v1/traces")
    url if url&.start_with?("http")
  end

  class Session
    def initialize(endpoint, traceparent, suite)
      _, trace, parent, = traceparent.to_s.split("-")
      @endpoint = endpoint
      @suite = suite
      @trace_id = [trace || SecureRandom.hex(16)].pack("H*")
      @parent = parent && [parent].pack("H*")
      @session = SecureRandom.bytes(8)
      @spans = []
      @failed = false
    end

    def start = @start = DaggerTestOtel.now
    def fail! = @failed = true

    def record(attrs, duration, errors)
      finish = DaggerTestOtel.now
      failed = attrs["test.case.result.status"] == "fail"
      @failed ||= failed
      events = errors.map { |error| DaggerTestOtel.exception(error, finish) }.join.b
      @spans << DaggerTestOtel.span(@trace_id, SecureRandom.bytes(8), @session, attrs["test.case.name"],
                                    finish - (duration * 1e9).to_i, finish, attrs, failed ? "test failed" : nil, events)
    end

    def export
      status = @failed ? "failure" : "success"
      session = DaggerTestOtel.span(@trace_id, @session, @parent, @suite, @start,
                                    DaggerTestOtel.now, { "test.suite.name" => @suite, "test.suite.run.status" => status },
                                    @failed ? "test session failed" : nil)
      scope = DaggerTestOtel.field(1, DaggerTestOtel.text(1, "dagger_test_otel")) +
              ([session] + @spans).map { |s| DaggerTestOtel.field(2, s) }.join.b
      resource = DaggerTestOtel.field(1, DaggerTestOtel.attributes(1, { "service.name" => @suite }))
      body = DaggerTestOtel.field(1, resource + DaggerTestOtel.field(2, scope))
      uri = URI(@endpoint)
      Timeout.timeout(5) do
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https",
                                            open_timeout: 2, read_timeout: 3, write_timeout: 3) do |http|
          http.post(uri.request_uri, body, "Content-Type" => "application/x-protobuf").value
        end
      end
    rescue StandardError => e
      warn "\ndagger_test_otel: spans not exported: #{e.class}: #{e.message}"
    end
  end
end
