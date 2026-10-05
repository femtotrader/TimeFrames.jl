# Changelog

All notable changes are documented here using the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.
The project follows [Semantic Versioning](https://semver.org/), including Julia
Pkg's compatibility convention for pre-1.0 packages.

## [Unreleased]

### Added

- Colon syntax for ranges with a timeframe step (#6).
- Weekly frequency strings accept `firstdayofweek` from Monday to Sunday (#9).
- Weekday-only business month frames and `BM` / `BMS` aliases (#2).
- Inclusive `date_range` and keyword `range` forms, with calendar boundary
  alignment and retained offsets for fixed beginning frames (#5, #31).
- Documentation for the distinction between period arithmetic and `tonext` (#39).
- Microsecond and nanosecond frames (`U` / `US`, `N` / `NS`) with precise
  subday grouping for Dates.Time and NanoDates.NanoDate; NanoDates is a test-only
  dependency (#18).
- Executable documentation examples for the `tf"5Min"` literal and both
  length-based range forms, completing the documentation follow-up in issue #30.

### Changed

- **Breaking:** lowercase `ms` denotes milliseconds rather than month start;
  use uppercase `MS` for month start (#43).
- **Breaking:** arithmetic and range construction reject submillisecond steps
  not exactly representable by DateTime, including generic period frames,
  rather than inheriting Dates' silent rounding (#18).

### Fixed

- Recompute the next calendar boundary rather than drifting when a preceding
  month has fewer days (#39).

## [0.8.0] - 2026-10-05

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

- Use native runner architecture in CI, with an explicit `macos-15` runner for
  Apple Silicon; macOS Intel is outside the CI matrix.
- Construct explicitly requested boundaries without mutating immutable frames.
- Accept `AbstractString` inputs, including substring views.
- Apply identity frames without changing the input and serialize them as `""`.
- Promote dates to datetimes for generic subday frame arithmetic.
- Reject generic calendar frame arithmetic on `Time` consistently.

### Removed

- Obsolete disabled documentation workflow, superseded by the active GitHub
  Actions documentation and Pages deployment workflow.

## Publication status

Version 0.8.0 is registered in General through JuliaRegistries/General#170649
and published as a GitHub release. The earlier 0.7.0 General
registration attempt from March 2025 was closed without merging, as tracked in
issue #57. A GitHub release does not itself update the registry; registration is
handled separately by Registrator. Unreleased changes target the next
compatibility series, 0.9, and are not included in the registered 0.8.0 tag.

Assisted-by: AI
