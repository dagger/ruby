# RuboCop

A [Dagger](https://dagger.io) module written in Dang that lints a Ruby project
with the RuboCop its `Gemfile.lock` pins and the configuration it carries.

## Install and run

```sh
dagger install github.com/dagger/ruby/rubocop
dagger check
```

The `lint` check runs `bundle exec rubocop` in the project root and fails with
RuboCop's offenses. `container` returns the prepared container for debugging:

```sh
dagger -c 'rubocop | container | terminal'
```

## Settings

```toml
[modules.rubocop.settings]
root = "services/api"
```

| Setting | Default | Meaning |
| --- | --- | --- |
| `root` | `"."` | Directory holding `Gemfile` and `Gemfile.lock`, relative to the workspace root, without `..` |
| `base` | official `ruby:4.0` image, pinned by digest | Container providing Ruby and Bundler |

## Supported projects

A project is supported when its root holds a `Gemfile` and a committed
`Gemfile.lock` that lists `rubocop`, in any group. Bundler runs frozen, so a
lockfile that no longer matches the Gemfile fails until you run `bundle lock`.

Ruby comes from `base` as it is: the module does not install the Ruby version a
Gemfile's `ruby` directive or `.ruby-version` asks for. Set `base` to an image
with a matching Ruby, and any system libraries native gems need.
