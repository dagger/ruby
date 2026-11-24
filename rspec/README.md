# RSpec

A [Dagger](https://dagger.io) module written in Dang that runs a Ruby project's
RSpec suite as `bundle exec rspec`.

```sh
dagger install github.com/dagger/ruby/rspec
dagger check
```

RSpec reads the project's `.rspec` and `spec/` as it does locally. `root` and
`base`, and the project requirements, are those of the
[`ruby` module](../ruby/README.md).

With `tracing` (on by default), a formatter sends a session span and one span
per example, with its outcome and failure exception class, to the trace Dagger
provides, as the [`minitest` module](../minitest/README.md) describes. It loads
through `SPEC_OPTS`, after any options already set there, and its formats
replace those of `.rspec`, so the output uses the progress format. Set
`tracing = false` to keep the project's formats.

The spec files under `spec/` named `*_spec.rb` form a collection with one check
per file; together they run the whole suite once. A suite whose `.rspec` points
elsewhere gets no checks, so `dagger check` runs none of it. Select files with
`--rspec-spec-file`, and only those run:

```sh
dagger check --rspec-spec-file=spec/models/user_spec.rb
```
