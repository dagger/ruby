# Rails

A [Dagger](https://dagger.io) module written in Dang that runs a Rails app's
tests as `bin/rails test`.

```sh
dagger install github.com/dagger/ruby/rails
dagger check
```

It runs `bin/rails test` only, not system tests. Rails loads `db/schema.rb` into
the test database, so an app whose test database is SQLite needs no services,
and only that database is created: the development database is not.

The default base has no Node, database command-line clients, credentials or
database services; set `base` to an image with what the app needs. `root` and
`base`, and the project requirements, are those of the [`ruby`
module](../ruby/README.md).