require "dagger_test_otel"

module DaggerTestOtel
  class MinitestReporter < Minitest::AbstractReporter
    def initialize(session)
      super()
      @session = session
    end

    def start = @session.start

    def record(result)
      outcome = if result.skipped? then "skipped" elsif result.passed? then "pass" else "fail" end
      attrs = { "test.case.name" => "#{result.klass}##{result.name}", "code.namespace" => result.klass,
                "code.function" => result.name, "test.case.result.status" => outcome }
      attrs["test.case.result.reason"] = result.failure.message if outcome == "skipped"
      errors = outcome == "fail" ? result.failures.map { |f| f.respond_to?(:error) ? f.error : f } : []
      @session.record(attrs, result.time, errors)
    end

    def report = @session.export
  end
end

module Minitest
  def self.plugin_dagger_otel_init(_options)
    endpoint = DaggerTestOtel.endpoint
    return unless endpoint

    session = DaggerTestOtel::Session.new(endpoint, ENV["TRACEPARENT"], ENV.fetch("DAGGER_TEST_SUITE", "minitest"))
    reporter << DaggerTestOtel::MinitestReporter.new(session)
  end
end
