# Ruby modules for Dagger

Installable [Dang](https://github.com/dagger/dang) modules for Ruby projects, one per tool,
laid out like [dagger/python](https://github.com/dagger/python), [dagger/go](https://github.com/dagger/go)
and [dagger/java](https://github.com/dagger/java). They require Dagger v1.0.0-beta.25 or later.

| Module | Runs |
| --- | --- |
| [`rubocop`](rubocop) | Lint and layout-only format |
| [`minitest`](minitest) | Minitest suite through `rake test` |
| [`rspec`](rspec) | RSpec suite |
| [`rails`](rails) | Tests on SQLite, development server, asset precompilation |
| [`bundler-audit`](bundler-audit) | Gemfile.lock advisory audit |
| [`brakeman`](brakeman) | Rails security scan |
| [`sorbet`](sorbet) | Type checking with `srb tc` |
| [`yard`](yard) | Documentation warnings and HTML build |
| [`ruby`](ruby) | Shared Bundler environment; install a tool module instead |

Each module is a directory with a `dagger-module.toml` and a `main.dang`; `dagger.toml` registers it
as a scope. End-to-end checks live in `.dagger/modules/e2e`.

Run the checks one at a time with `dagger check <name>`; `dagger check -l` lists them.
