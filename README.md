# TimeFrames

A Julia library that defines time buckets for grouping and resampling time series.
Supports Julia 1.10 and later; tested on Julia 1.10 (LTS) and Julia 1.13.

## Install

```julia
using Pkg
Pkg.add("TimeFrames")
```

## Usage

```julia
julia> using Dates, TimeFrames

julia> tf = TimeFrame("5T");

julia> apply(tf, DateTime(2016, 9, 11, 20, 9))
2016-09-11T20:05:00

julia> apply(TimeFrame("2H"), DateTime(2016, 9, 11, 20, 9))
2016-09-11T20:00:00
```

See the [usage guide](docs/src/usage.md), [API reference](docs/src/api.md), and
[migration guide](docs/src/migration.md). Version 0.8.0 is registered in General
and published as a GitHub release. See the
[changelog](CHANGELOG.md) before upgrading from 0.2.0.
Version 0.9.0 adds calendar ranges, weekly anchors, business months, and optional
NanoDates integration. It contains breaking changes to the `ms` alias and
submillisecond DateTime operations; see the migration guide before upgrading.
The documentation workflow publishes to
[GitHub Pages](https://femtotrader.github.io/TimeFrames.jl/) after validated builds
on `main`.

## Development

Install Juliaup and just, then run:

```sh
juliaup add 1.10
juliaup add 1.13
just check
```

Tests use TestItemRunner and include Aqua quality checks. JuliaFormatter checks
run in CI and through `just format-check`. Documentation under `docs/` uses
Documenter and DocumenterLandingPage. Builds run executable examples,
fail on warnings, and produce HTML, `llms.txt`, and `llms-full.txt` in a temporary
output directory. See [contributing](CONTRIBUTING.md) for commands and release
validation.

This library has been used by

- [TimeSeriesResampler.jl](https://github.com/femtotrader/TimeSeriesResampler.jl)
- [TimeSeriesIO.jl](https://github.com/femtotrader/TimeSeriesIO.jl)

Assisted-by: AI
