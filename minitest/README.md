# Minitest

A [Dagger](https://dagger.io) module written in Dang that runs a Ruby project's
Minitest suite as `bundle exec rake test`.

```sh
dagger install github.com/dagger/ruby/minitest
dagger check
```

The project's `Rakefile` defines the `test` task, for example with
`Minitest::TestTask.create`. `root` and `base`, and the project requirements,
are those of the [`ruby` module](../ruby/README.md).

With `tracing` (on by default), the bundled `dagger_minitest_otel` plugin sends
a session span and one span per test, with its outcome, skip reason and failure
exception class, to the trace Dagger provides. Failure messages and backtraces
are not exported: Dagger masks secrets in test output but not in spans, so they
stay in the output. The plugin uses only Ruby's standard library and loads
through `RUBYOPT` after the bundle is installed, so the project's Gemfile and
lock are untouched. Minitest 6 is tested; 5 is untested. A failed export only
warns. Set `tracing = false` to run without it.