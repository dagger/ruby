# Rails

A [Dagger](https://dagger.io) module written in Dang that tests a Rails app and
serves it for local development.

```sh
dagger install github.com/dagger/ruby/rails
dagger check
```

Its tests run as `bundle exec bin/rails test`, not system tests. Rails loads
`db/schema.rb` into the test database, so an app whose test database is SQLite
needs no services, and only that database is created: the development database
is not.

With `tracing` (on by default), each test is a span in the trace Dagger
provides, exported as the [`minitest` module](../minitest/README.md) describes,
under a session span named `rails`. The test files `bin/rails test` runs by
default form a collection with one check per file; together they run the tests
once, and an app with no such files gets no checks. Select files with
`--rails-test-file`, and only those run:

```sh
dagger check --rails-test-file=test/models/user_test.rb
```

`server` is the module's `dagger start` service: `bin/rails server` in
development on port 3000, answering only Rails' development hosts such as
`localhost`. It needs a Rack server such as `puma` in the lockfile and the
app's `config.ru`. No migrations run; a request that queries the database
fails until the app's development database exists.

`assets` is an explicit function, never a check: it runs
`bin/rails assets:precompile` in production with Rails' `SECRET_KEY_BASE_DUMMY`
and returns `public/assets`:

```sh
dagger -c 'rails | assets | export public/assets'
```

The default base has no Node, database command-line clients, credentials or
database services; set `base` to an image with what the app needs, such as Node
for JavaScript-bundled assets. `root` and `base`, and the project requirements,
are those of the [`ruby` module](../ruby/README.md).