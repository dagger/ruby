# Ruby modules for Dagger

Installable [Dang](https://github.com/dagger/dang) modules for Ruby projects, one per tool,
laid out like [dagger/python](https://github.com/dagger/python), [dagger/go](https://github.com/dagger/go)
and [dagger/java](https://github.com/dagger/java).

Status: bootstrap. Modules land one pull request at a time:

| Module | Status |
| --- | --- |
| `rubocop` | first slice |
| `ruby` (shared Bundler environment), Minitest, RSpec, Rails, bundler-audit, Brakeman | planned |

Each module is a directory with a `dagger-module.toml` and a `main.dang`; `dagger.toml` registers it
as a scope. End-to-end checks live in `.dagger/modules/e2e`.
