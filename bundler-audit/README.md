# bundler-audit

A [Dagger](https://dagger.io) module written in Dang that audits a Ruby
project's `Gemfile.lock` with
[bundler-audit](https://github.com/rubysec/bundler-audit).

```sh
dagger install github.com/dagger/ruby/bundler-audit
dagger check
```

The `audit` check installs the project's gems first, like every module in this
family, so an app whose bundle cannot install cannot be audited. It then runs
bundler-audit 0.9.3 outside the project's bundle, so the project does not need
it in its Gemfile. Every run downloads the current
[ruby-advisory-db](https://github.com/rubysec/ruby-advisory-db) and needs
network access; the verdict for an unchanged lockfile changes as advisories are
published.

`root` and `base`, and the project requirements, are those of the
[`ruby` module](../ruby/README.md).
