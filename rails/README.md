# Rails

A [Dagger](https://dagger.io) module written in Dang that tests a Rails app and
serves it for local development.

```sh
dagger install github.com/dagger/ruby/rails
dagger check
```

Its `test` check runs `bin/rails test`, not system tests. Rails loads
`db/schema.rb` into the test database, so an app whose test database is SQLite
needs no services, and only that database is created: the development database
is not.

`server` is the module's `dagger start` service: `bin/rails server` in
development on port 3000, answering only Rails' development hosts such as
`localhost`. It needs a Rack server such as `puma` in the lockfile and the
app's `config.ru`. No migrations run; a request that queries the database
fails until the app's development database exists.

The default base has no Node, database command-line clients, credentials or
database services; set `base` to an image with what the app needs. `root` and
`base`, and the project requirements, are those of the [`ruby`
module](../ruby/README.md).