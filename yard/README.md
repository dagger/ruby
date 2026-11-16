# YARD

A [Dagger](https://dagger.io) module written in Dang that checks and builds a
Ruby project's [YARD](https://yardoc.org) documentation.

```sh
dagger install github.com/dagger/ruby/yard
dagger check
```

The `docs` check runs `bundle exec yard doc --fail-on-warning --verbose` with
the YARD the project's `Gemfile.lock` pins and its own `.yardopts`, and fails on
any YARD warning, such as an `@param` that names no argument, even if
`.yardopts` sets `--quiet`. The `build` function runs the same command and
returns the generated HTML:

```sh
dagger -c 'yard | build | export docs'
```

`yard` may be in any group. `root` and `base`, and the project requirements,
are those of the [`ruby` module](../ruby/README.md).
