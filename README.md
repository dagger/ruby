# Ruby modules for Dagger

Installable [Dang](https://github.com/dagger/dang) modules for Ruby projects, one per tool,
laid out like [dagger/python](https://github.com/dagger/python), [dagger/go](https://github.com/dagger/go)
and [dagger/java](https://github.com/dagger/java). They require Dagger v1.0.0-beta.25 or later.

Modules land one pull request at a time:

| Module | Status |
| --- | --- |
| [`ruby`](ruby) (shared Bundler environment) | available |
| [`rubocop`](rubocop) | available |
| [`minitest`](minitest) | available |
| [`rspec`](rspec) | available |
| [`rails`](rails) (SQLite test database) | available |
| bundler-audit, Brakeman | planned |

Each module is a directory with a `dagger-module.toml` and a `main.dang`; `dagger.toml` registers it
as a scope. End-to-end checks live in `.dagger/modules/e2e`.

Run the checks one at a time with `dagger check <name>`; `dagger check -l` lists them.
