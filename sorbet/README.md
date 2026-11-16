# Sorbet

A [Dagger](https://dagger.io) module written in Dang that type-checks a Ruby
project with [Sorbet](https://sorbet.org).

```sh
dagger install github.com/dagger/ruby/sorbet
dagger check
```

The `typecheck` check runs `bundle exec srb tc` in the project root, with the
Sorbet version the project's `Gemfile.lock` pins and its own `sorbet/config`,
and fails with Sorbet's errors. `sorbet` may be in any group.

Sorbet only; Steep and RBS are not covered. Committed RBIs (for example from
Tapioca) are the project's job.

The lock must list the `x86_64-linux` or `aarch64-linux` platform (add it with
`bundle lock --add-platform x86_64-linux`). A musl/Alpine `base` cannot run
Sorbet; the default glibc `ruby:4.0` image works.

`root` and `base`, and the project requirements, are those of the
[`ruby` module](../ruby/README.md).
