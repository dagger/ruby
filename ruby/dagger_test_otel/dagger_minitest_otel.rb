# RUBYOPT loads this into every Ruby process. It acts only after Bundler has
# set up the project's gems, so it never activates a Minitest other than the
# one the lockfile pins.
if $LOADED_FEATURES.any? { |path| path.end_with?("/bundler/setup.rb") }
  begin
    require "minitest"
    if !defined?(Minitest::AbstractReporter)
      warn "dagger_minitest_otel: Minitest #{Minitest::VERSION} is too old; tracing skipped"
    elsif Minitest::VERSION.to_i >= 6
      # Minitest 6 loads only registered plugins. Minitest 5 finds this one on
      # the load path itself, and registering it there would stop the
      # discovery of the project's other plugins.
      require "minitest/dagger_otel_plugin"
      Minitest.register_plugin("dagger_otel") unless Minitest.extensions.include?("dagger_otel")
    end
  rescue LoadError
    nil
  end
end
