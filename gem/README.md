# Gem

A [Dagger](https://dagger.io) module written in Dang that builds a Ruby
project's gem with `gem build`.

```sh
dagger install github.com/dagger/ruby/gem
dagger check
```

`build` returns the `.gem` file built from the single `.gemspec` at the project
root; the `gemspec` check fails when that build fails. Nothing is published.

The project root must hold exactly one `.gemspec`. Its `spec.files` must not
shell out to git: the workspace is copied without `.git`, so `git ls-files`
lists nothing. A gem without files fails with `spec.files is empty`; list files
with `Dir[...]` globs instead. `root` and
`base`, and the project requirements, are those of the
[`ruby` module](../ruby/README.md).
