# Usage

## Frequency strings

Strings accept an optional positive integer magnitude followed by one unit.
Units are case insensitive except for `ms` and `MS`; whitespace, signed magnitudes, and fractional
magnitudes are rejected with `ArgumentError`.

| Unit | Meaning | Default boundary |
| --- | --- | --- |
| `A` | Year | End |
| `AS` | Year | Begin |
| `M` | Month | End |
| `MS` | Month | Begin |
| `BM` | Business month (weekdays only) | End |
| `BMS` | Business month (weekdays only) | Begin |
| `W` | Week | Begin |
| `D` | Day | Begin |
| `H` | Hour | Begin |
| `T`, `MIN` | Minute | Begin |
| `S` | Second | Begin |
| `L`, `ms` | Millisecond | Begin |

`MS` means month start; lowercase `ms` means milliseconds. Use `L` for the
case-insensitive millisecond alias. Mixed-case `Ms` and `mS` remain month start.
The empty string and `TimeFrame()` create `NoTimeFrame()`.
`String` returns the canonical unit for named period frames, such as `15T`.
It returns the empty string for an identity frame. Generic Dates period frames
and custom grouping functions do not have frequency-string serialization.

### String literal macro

The `tf"..."` macro uses the same frequency parser as `TimeFrame("...")`.
For example, the mixed-case `Min` alias means minutes:

```jldoctest
julia> using Dates, TimeFrames

julia> String(tf"5Min")
"5T"

julia> apply(tf"5Min", DateTime(2024, 1, 1, 12, 9))
2024-01-01T12:05:00
```

## Boundaries

Beginning frames use `floor`. End frames use `ceil` and subtract one day for
`Date` or one millisecond for `DateTime`. At an exact ceiling boundary, this
selects the preceding bucket's final instant. This historical behavior is
preserved, including month, year, and week alignment from Dates.

```jldoctest
julia> using Dates, TimeFrames

julia> apply(TimeFrame("5T"; boundary=End), DateTime(2024, 1, 1, 12, 2))
2024-01-01T12:04:59.999

julia> apply(MonthEnd(), Date(2024, 2, 20))
2024-02-29

julia> apply(NoTimeFrame(), DateTime(2024, 1, 1))
2024-01-01T00:00:00
```

Calendar frames may return `Date` when Dates rounding does so. Consumers should
not assume that every `apply` call on a `DateTime` returns a `DateTime`.
Period frames support `Date` and `DateTime` where Dates provides rounding.
For `Time`, use arithmetic, an identity frame, or a custom grouping function.

### Weekly anchors and business months

Weekly frames default to Monday. Specify `firstdayofweek=7` for Sunday;
integers 1 through 7 follow Dates' Monday-to-Sunday numbering.
The keyword applies only to frequency strings for weekly frames.

Business months select the first or last Monday-to-Friday date within the
month bucket. They do not account for public holidays or exchange calendars;
use a custom grouping function for those rules.

```jldoctest
julia> using Dates, TimeFrames

julia> apply(TimeFrame("W"; firstdayofweek=7), Date(2024, 1, 3))
2023-12-31

julia> apply(tf"BM", Date(2024, 3, 15))
2024-03-29

julia> apply(tf"BMS", Date(2024, 6, 15))
2024-06-03
```

`TimeFrames.tonext` finds the next boundary label, recalculating calendar
boundaries rather than adding a month to a previous month-end date.
Arithmetic (`date + frame`) adds the underlying period; use `tonext` when
you want a boundary instead. Its qualified name avoids confusion with Dates.

```jldoctest
julia> using Dates, TimeFrames

julia> TimeFrames.tonext(tf"M", Date(2024, 2, 29))
2024-03-31

julia> TimeFrames.tonext(tf"M", Date(2024, 2, 29); same=true)
2024-02-29
```

## Arithmetic and custom grouping

Period frames support adding to and subtracting from time values, and multiplying
the frame by an integer. Adding a subday frame to a `Date` promotes to `DateTime`.
Adding a calendar frame to a `Time` throws `InexactError`.

```jldoctest
julia> using Dates, TimeFrames

julia> Date(2024, 1, 1) + tf"2H"
2024-01-01T02:00:00

julia> String(3 * tf"5T")
"15T"

julia> tf = TimeFrame(dt -> floor(dt, Dates.Minute(15)));

julia> apply(tf, DateTime(2024, 1, 1, 12, 19))
2024-01-01T12:15:00
```

## Ranges

Use `date_range(start, frame, stop)` or `range(start, frame; stop=stop)` for
inclusive bounds. Month, year, week, and business-month frames use calendar
labels recalculated for each bucket. Other beginning frames retain the start's
time of day; `normalize=true` on `date_range` aligns them to bucket starts.
The result of `date_range` is an eagerly allocated vector. For a lazy sequence
of underlying periods without bucket alignment, use colon syntax.

```jldoctest
julia> using Dates, TimeFrames

julia> date_range(Date(2024, 1, 1), tf"M", Date(2024, 3, 31))
3-element Vector{Date}:
 2024-01-31
 2024-02-29
 2024-03-31

julia> collect(range(Date(2024, 1, 1), tf"D"; length=2))
2-element Vector{Date}:
 2024-01-01
 2024-01-02
```

Unlike pandas' midnight month-end offsets, TimeFrames end labels for `DateTime`
are the final millisecond of the final day. Use `Date` inputs for date-only labels.
Frequency strings describe buckets, not the complete pandas DateOffset API.

Colon syntax uses the underlying Dates period, preserves the start's offset,
and includes the stop when it lies on the step sequence. It does not round
values according to the frame's boundary policy.

```jldoctest
julia> using Dates, TimeFrames

julia> collect(Date(2024, 1, 1):tf"D":Date(2024, 1, 3))
3-element Vector{Date}:
 2024-01-01
 2024-01-02
 2024-01-03

julia> String(tf"250ms")
"250L"
```

The endpoint form excludes the stop value and rounds both endpoints by default.
Use `apply_tf=false` to retain the start's offset. Length-based forms retain
offsets; the form starting with a frame constructs values preceding the stop.

```jldoctest
julia> using Dates, TimeFrames

julia> collect(range(Date(2024, 1, 1), tf"D", Date(2024, 1, 4)))
3-element Vector{Date}:
 2024-01-01
 2024-01-02
 2024-01-03

julia> collect(range(Date(2024, 1, 1), tf"D", 2))
2-element Vector{Date}:
 2024-01-01
 2024-01-02

julia> collect(range(tf"D", Date(2024, 1, 4), 2))
2-element Vector{Date}:
 2024-01-02
 2024-01-03
```
