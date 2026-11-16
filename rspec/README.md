# RSpec

A [Dagger](https://dagger.io) module written in Dang that runs a Ruby project's
RSpec suite as `bundle exec rspec`.

```sh
dagger install github.com/dagger/ruby/rspec
dagger check
```

RSpec reads the project's `.rspec` and `spec/` as it does locally. `root` and
`base`, and the project requirements, are those of the
[`ruby` module](../ruby/README.md).
