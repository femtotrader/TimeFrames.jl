# Contributing

Use English for source, comments, tests, and documentation. Keep commits in
Conventional Commit format, such as `fix: validate frequency strings`.

## Development setup

Install [Juliaup](https://github.com/JuliaLang/juliaup) and
[just](https://github.com/casey/just), then run:

```sh
juliaup add 1.10
juliaup add 1.13
just check
```

`just test 1.10` and `just test 1.13` run the complete suite, including Aqua.
`just docs 1.10` and `just docs 1.13` build documentation with strict checks and
doctests. Equivalent commands without just are:

```sh
julia +1.10 --startup-file=no --project=. -e 'using Pkg; Pkg.test()'
julia +1.13 --startup-file=no --project=. -e 'using Pkg; Pkg.test()'
julia +1.10 --startup-file=no --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'
julia +1.10 --startup-file=no --project=docs docs/make.jl
```

Repeat the documentation setup and build commands with `+1.13` to verify that
version too.
The documentation output defaults to `timeframes-docs` in the system temporary
directory. Set `TIMEFRAMES_DOCS_BUILD` to select another output directory.
Both `llms.txt` and `llms-full.txt` are generated during the build.

Documentation sources and their DocumenterLandingPage home page are maintained
under `docs/`; generated pages are build output, not repository-root files.
Serve the output with an HTTP server to browse directory-style URLs locally,
for example `python3 -m http.server --directory /tmp/timeframes-docs`.

The documentation workflow builds on both supported Julia versions. On `main`,
it uploads the Julia 1.10 build as a Pages artifact and deploys with GitHub Actions
after both builds pass. Pull requests and version tags validate and archive the
documentation. The repository's Pages source must be GitHub Actions; its current
environment policy allows deployment from `main`.
This serves a single documentation site at
`https://femtotrader.github.io/TimeFrames.jl/`; each eligible deployment replaces
that site. No generated documentation is committed to the repository root.

## Automated quality checks

Tests use TestItemRunner for isolated component and package-quality items. Aqua
checks are part of the complete suite on both supported Julia versions.

```sh
just format        # Apply JuliaFormatter to maintained Julia files.
just format-check  # Verify formatting without changing files.
```

The formatter runs in the separate `dev/` environment, using the repository's
`.JuliaFormatter.toml` configuration. CI checks formatting independently of tests.
Optionally install pre-commit and run `pre-commit install` to enable the local
formatting hook.

Dependabot updates GitHub Actions weekly. CompatHelper checks dependency bounds
in the package, docs, and development environments. TagBot creates release tags
after registry registration; it does not perform registration itself.
To make TagBot-created tags trigger subsequent validation workflows, configure
the `DOCUMENTER_KEY` SSH secret with a repository deploy key before publication.
GitHub Pages deployment on `main` uses the workflow's token permissions and does
not need that key.

## Changes

Write a regression test and observe its failure before fixing code. Describe new
features in `docs/src/`, record notable changes in `CHANGELOG.md`, and include
migration instructions for incompatible changes. Run tests and build docs without
warnings before committing code changes.

The supported minimum is Julia 1.10; Julia 1.13 is also tested. Record exact Julia,
package, and relevant dependency versions with bug reports. Record upstream bugs
in `upstream-bugs.md` only when an upstream defect has been identified.

Use semantic versioning and check General before proposing a release number.
Milestones describe development progress and do not themselves create releases.
Publishing follows migration validation.

Do not stage local agent instruction files or local specifications. The gitignore
allowlist excludes local manifests, coverage files, and documentation build output.
When AI assists a contribution, disclose it as `Assisted-by: AI`, without a model
name or a coauthor trailer.

## Release validation

Review [the migration guide](docs/src/migration.md), run `just check`, confirm
supported-version CI is green, and prepare release notes describing breaking
changes before invoking Registrator. A Git tag alone does not register a version.

Assisted-by: AI
