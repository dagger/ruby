# Ruby

The shared Bundler environment behind the Ruby tool modules, such as
[`rubocop`](../rubocop) and [`minitest`](../minitest). Each tool takes these
settings and passes them here.

| Setting | Default | Meaning |
| --- | --- | --- |
| `root` | `"."` | Directory holding `Gemfile` and `Gemfile.lock`, relative to the workspace root, without `..` |
| `base` | official `ruby:4.0` image, pinned by digest | Container providing Ruby and Bundler |

A project's root must hold a `Gemfile` and a committed `Gemfile.lock` that
includes the tool's gem. Bundler runs frozen, so a lockfile that no longer
matches the Gemfile fails with Bundler's own message until you run
`bundle lock`. Development and test groups are always installed, whatever
`BUNDLE_WITHOUT` or `.bundle/config` says.

`lockfileContainer` gives the same environment without installing gems and
with `Gemfile.lock` writable, for tools that change the lockfile; it needs
only a `Gemfile`.

Ruby comes from `base` as it is: the environment does not install the Ruby
version a Gemfile's `ruby` directive or `.ruby-version` asks for. Set `base` to
an image with a matching Ruby, and any system libraries native gems need.
