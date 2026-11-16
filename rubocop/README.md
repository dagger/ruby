# RuboCop

A [Dagger](https://dagger.io) module written in Dang that lints a Ruby project
with the RuboCop its `Gemfile.lock` pins and the configuration it carries.

## Install and run

```sh
dagger install github.com/dagger/ruby/rubocop
dagger check
```

The `lint` check runs `bundle exec rubocop` in the project root and fails with
RuboCop's offenses.

## Settings

`root` and `base`, and the project requirements, are those of the
[`ruby` module](../ruby/README.md). `rubocop` may be in any group.

```toml
[modules.rubocop.settings]
root = "services/api"
```
