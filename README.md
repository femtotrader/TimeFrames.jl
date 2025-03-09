# TimeFrames

A Julia library that defines TimeFrames (essentially for resampling TimeSeries).

## Install

```julia
julia> Pkg.add("TimeFrames")
```

## Usage

```julia
julia> using TimeFrames

julia> tf = TimeFrame("5T")
TimeFrames.Minute(5 minutes,Begin::TimeFrames.Boundary = 1)

julia> apply(tf, DateTime(2016, 9, 11, 20, 9))
2016-09-11T20:05:00

julia> apply(TimeFrame("2H"), DateTime(2016, 9, 11, 20, 9))
2016-09-11T20:00:00
```

This library is (was) used by

- [TimeSeriesResampler.jl](https://github.com/femtotrader/TimeSeriesResampler.jl)
- [TimeSeriesIO.jl](https://github.com/femtotrader/TimeSeriesIO.jl)
