# Brakeman

A [Dagger](https://dagger.io) module written in Dang that scans a Rails app with
[Brakeman](https://brakemanscanner.org).

```sh
dagger install github.com/dagger/ruby/brakeman
dagger check
```

The `scan` check installs the project's gems first, like every module in this
family, so an app whose bundle cannot install cannot be scanned. It then runs a
pinned Brakeman outside the project's bundle, so the app does not need it in
its Gemfile, and needs network access to fetch that gem. It fails on any
non-ignored warning or scan error. Brakeman reads the app's own
`config/brakeman.yml` and `config/brakeman.ignore`.

`root` and `base`, and the project requirements, are those of the
[`ruby` module](../ruby/README.md).
