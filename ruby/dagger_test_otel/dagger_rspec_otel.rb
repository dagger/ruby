require "dagger_test_otel"

class DaggerRspecOtel
  RSpec::Core::Formatters.register self, :start, :example_passed, :example_failed, :example_pending, :close

  def initialize(_output)
    endpoint = DaggerTestOtel.endpoint
    @session = endpoint && DaggerTestOtel::Session.new(endpoint, ENV["TRACEPARENT"], "rspec")
  end

  def start(_notification) = @session&.start
  def example_passed(notification) = record(notification.example, "pass")
  def example_failed(notification) = record(notification.example, "fail")
  def example_pending(notification) = record(notification.example, "skipped")

  def close(_notification)
    return unless @session

    @session.fail! if RSpec.world.non_example_failure
    @session.export
  end

  private

  def record(example, outcome)
    return unless @session

    result = example.execution_result
    attrs = { "test.case.name" => example.full_description, "test.case.result.status" => outcome,
              "code.filepath" => "#{example.file_path}:#{example.metadata[:line_number]}" }
    attrs["test.case.result.reason"] = result.pending_message if outcome == "skipped"
    @session.record(attrs, result.run_time, outcome == "fail" ? [result.exception] : [])
  end
end
