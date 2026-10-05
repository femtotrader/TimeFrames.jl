# Changelog

All notable changes are documented here using the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.
The project follows [Semantic Versioning](https://semver.org/), including Julia
Pkg's compatibility convention for pre-1.0 packages.

## [Unreleased]

### Added

- Regression tests for explicit boundaries, invalid frequency strings, identity
  frames, and generic period arithmetic.
- Aqua.jl package quality checks.
- Modular test items with TestItemRunner and automated JuliaFormatter checks.
- Optional local pre-commit formatting hook and a dedicated formatting CI job.
- DocumenterLandingPage documentation home page under `docs/`.
- GitHub Actions deployment to GitHub Pages after both supported-version
  documentation builds pass, with archived HTML and LLM documentation files.
- Documentation with executable examples, migration guidance, and generated
  `llms.txt` and `llms-full.txt` files.
- Juliaup-based development commands through a justfile.
- Contributor guidance, GHSA-only private security reporting, and community code
  of conduct.

### Changed

- Replace the registered 0.2.0 package's legacy `REQUIRE` metadata with
  `Project.toml` and explicit dependency compatibility.
- **Breaking:** require Julia 1.10 or later, replacing the declared minimum 1.6.7.
- **Breaking:** reject zero string magnitudes and numeric-only frequency strings.
- **Breaking:** consistently throw `ArgumentError` for invalid frequency strings.
- **Breaking:** scoped boundary enum values display as uppercase names; existing
  `Boundary`, `Begin`, and `End` aliases and integer values remain available.
- Test Julia 1.10 LTS and Julia 1.13 on Linux, Windows, and macOS; report nightly
  failures without blocking supported versions.
- Use an allowlist in `.gitignore` for maintained package files.
- Remove personal email addresses from package metadata and reporting policies.
- Check dependency compatibility in package, docs, and formatter environments
  with CompatHelper; restrict workflow permissions to their required operations.

### Fixed

- Construct explicitly requested boundaries without mutating immutable frames.
- Accept `AbstractString` inputs, including substring views.
- Apply identity frames without changing the input and serialize them as `""`.
- Promote dates to datetimes for generic subday frame arithmetic.
- Reject generic calendar frame arithmetic on `Time` consistently.

### Removed

- Obsolete disabled documentation workflow, superseded by the active GitHub
  Actions documentation and Pages deployment workflow.

## Publication status

The repository's version is 0.7.0. Its March 2025 registration attempt was closed
without merging, as tracked in issue #57. This changelog does not claim that
0.7.0 was released. Registration will follow migration and validation.

Assisted-by: AI
