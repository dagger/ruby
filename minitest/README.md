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

With `tracing` (on by default), the `ruby` module's test exporter sends a
session span and one span per test, with its outcome, skip reason and failure
exception class, to the trace Dagger provides, so Dagger lists each test.
Failure messages and backtraces are not exported: Dagger masks secrets in test
output but not in spans, so they stay in the output. The exporter uses only
Ruby's standard library and loads through `RUBYOPT` after the bundle is
installed, so the project's Gemfile and lock are untouched. Minitest 6 is
tested; 5 is untested. A failed export only warns. Set `tracing = false` to
run without it.

The test files under `test/` named `test_*.rb` or `*_test.rb`, as
`Minitest::TestTask` finds by default, form a collection with one check per
file; together they run the whole suite once. A suite whose files lie elsewhere
gets no checks, so `dagger check` runs none of it. Select files with
`--minitest-test-file`; a selection that leaves files out runs only those, with
Minitest 6's `minitest` runner instead of `rake test`, so it skips the
Rakefile's prerequisites and test task settings:

```sh
dagger check --minitest-test-file=test/models/user_test.rb
```