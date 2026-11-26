# bundle

A [Dagger](https://dagger.io) module written in Dang that updates a Ruby
project's `Gemfile.lock` with `bundle lock --update` and returns the change as
a changeset.

```sh
dagger install github.com/dagger/ruby/bundle
dagger api call bundle update --gems puma export --path .
```

Run the second command from the workspace root. `update` updates the gems
given with `--gems`, or every gem when none is given, and `export --path .`
applies the changeset to the workspace. The changeset only ever holds
`Gemfile.lock`, whether or not Git ignores it; a project without one gets a
new lockfile. With one or more gems, `bundle lock` runs with `--conservative`, so
the gems' shared dependencies keep their locked versions; pass
`--conservative=false` to let them move.

Bundler resolves gems without installing them, so a lockfile whose gems cannot
install can still be updated. Each Dagger session reads the current gem index
and needs network access; the same call returns a different lockfile as gems
are published.

`update` is neither a generator nor a check: `dagger generate` and
`dagger check` never run it, and you call it when you want an update.

`root` and `base` are those of the [`ruby` module](../ruby/README.md); the
project root needs a `Gemfile`.
