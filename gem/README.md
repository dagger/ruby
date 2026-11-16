# Gem

A [Dagger](https://dagger.io) module written in Dang that builds a Ruby
project's gem with `gem build`.

```sh
dagger install github.com/dagger/ruby/gem
dagger check
```

`build` returns the `.gem` file built from the single `.gemspec` at the project
root; the `gemspec` check fails when that build fails. Checks never publish.

`publish` is a deliberate, explicit action: it builds the gem the same way and
runs `gem push` to the `host` you pass, with the API key as a secret in
`GEM_HOST_API_KEY`. A push always runs; it is never served from cache.

```sh
dagger -c 'gem | publish --host https://gems.example.invalid --api-key env://GEM_HOST_API_KEY'
```

`host` has no default: a real release passes the registry URL explicitly.
`gem-publish-check` exercises `publish` against a local mock server; it has
never been run against rubygems.org. No OTP support: use an API key allowed to
push without MFA.

The project root must hold exactly one `.gemspec`. Its `spec.files` must not
shell out to git: the workspace is copied without `.git`, so `git ls-files`
lists nothing. A gem without files fails with `spec.files is empty`; list files
with `Dir[...]` globs instead. `root` and
`base`, and the project requirements, are those of the
[`ruby` module](../ruby/README.md).
