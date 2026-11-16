# Minitest

A [Dagger](https://dagger.io) module written in Dang that runs a Ruby project's
Minitest suite as `bundle exec rake test`.

```sh
dagger install github.com/dagger/ruby/minitest
dagger check
```

The project's `Rakefile` defines the `test` task, for example with
`Minitest::TestTask.create`. `root` and `base`, and the project requirements,
are those of the [`ruby` module](../ruby/README.md).
