# TimeFrames.jl

```@raw html
---
layout: home
hero:
  name: TimeFrames.jl
  text: Time buckets for Julia
  tagline: Group and resample dates and datetimes with explicit bucket boundaries.
  actions:
    - theme: brand
      text: Usage guide
      link: /usage/
    - theme: alt
      text: View on GitHub
      link: https://github.com/femtotrader/TimeFrames.jl
features:
  - icon: 🕒
    title: Periods and frequencies
    details: Construct frames from Dates periods or concise frequency strings.
    link: /usage/
  - icon: 📅
    title: Calendar boundaries
    details: Group by month, year, week, or subday intervals.
    link: /api/
  - icon: 🧪
    title: Supported and tested
    details: Supports Julia 1.10 LTS and Julia 1.13 with tested examples.
    link: /migration/
---
```

TimeFrames defines time buckets for grouping and resampling Julia time values.
It uses the Dates standard library and supports Julia 1.10 and later.

## Installation

```julia
using Pkg
Pkg.add("TimeFrames")
```

The migration is being prepared for publication. Until a modern version is
registered, use the repository explicitly to test the migrated package:

```julia
using Pkg
Pkg.add(url="https://github.com/femtotrader/TimeFrames.jl", rev="main")
```

For local development, use `Pkg.develop(path="/path/to/TimeFrames.jl")`.
Record the commit hash when testing an unreleased repository revision.

## Quick start

```jldoctest
julia> using Dates, TimeFrames

julia> apply(tf"5T", DateTime(2024, 1, 1, 12, 9))
2024-01-01T12:05:00

julia> Date(2024, 1, 1) + TimeFrame(Dates.Hour(2))
2024-01-01T02:00:00
```

See [Usage](@ref), [Migration](@ref), and [API reference](@ref) for supported
frequencies, boundary behavior, and upgrade instructions.

Documentation builds also produce `llms.txt` and `llms-full.txt` alongside HTML.

Assisted-by: AI
