module TimeFrames

import Base: range, +, -, *

using Dates

export TimeFrame, Boundary
export YearBegin, YearEnd
export MonthBegin, MonthEnd
# export Millisecond, Second, Minute, Hour, Day, Week
export NoTimeFrame
export apply, range, date_range
export BusinessMonthBegin, BusinessMonthEnd
export Begin, End
export @tf_str

"""
    TimeFrame(frequency::AbstractString; boundary=TimeFrames.UndefBoundary, firstdayofweek=nothing)
    TimeFrame(period::Dates.Period; boundary=Begin)
    TimeFrame(grouper::Function)
    TimeFrame()

Construct a time bucket from a frequency, a Dates period, or a custom grouping
function. An empty string or no argument creates an identity frame.

Supported frequency units are `A`, `AS`, `M`, `MS`, `W`, `D`, `H`, `T` (or
`MIN`), `S`, `L` (or lowercase `ms`), `U` (or `US`), and `N` (or `NS`).
Units are case insensitive except
that `ms` means milliseconds and `MS` means month start. Units may have a positive integer
prefix. `A` and `M` default to `End`; other units default to `Begin`.
Invalid strings throw `ArgumentError`.
Business-month aliases `BM` and `BMS` exclude weekends, but not holidays.
Weekly frames accept `firstdayofweek` from 1 (Monday) to 7 (Sunday).
"""
abstract type TimeFrame end

module BoundaryPolicy
@enum T UNDEFINED = 0 BEGIN = 1 END = 2
end

"""
    Boundary

Time bucket boundary policy, an alias for `TimeFrames.BoundaryPolicy.T`.
`Begin` uses the start of a bucket; `End` uses the ceiling boundary minus one day
for `Date` or one millisecond for `DateTime`.
"""
const Boundary = BoundaryPolicy.T
const UndefBoundary = BoundaryPolicy.UNDEFINED
const Begin = BoundaryPolicy.BEGIN
const End = BoundaryPolicy.END

@doc "Select the beginning of a time bucket using Dates rounding." Begin
@doc "Select the ceiling boundary minus the input type's smallest step." End

#T should be Dates.TimePeriod

abstract type AbstractPeriodFrame <: TimeFrame end
abstract type AbstractTimePeriodFrame <: AbstractPeriodFrame end
abstract type AbstractDatePeriodFrame <: AbstractPeriodFrame end

struct TimePeriodFrame{T<:Dates.TimePeriod} <: AbstractTimePeriodFrame
    period::T
    boundary::Boundary
end
TimePeriodFrame{T}(; boundary = Begin::Boundary) where {T<:Dates.TimePeriod} =
    TimePeriodFrame(T(1), boundary)
TimePeriodFrame{T}(
    n::Integer;
    boundary = Begin::Boundary,
) where {T<:Dates.TimePeriod} = TimePeriodFrame(T(n), boundary)

struct DatePeriodFrame{T<:Dates.DatePeriod} <: AbstractDatePeriodFrame
    period::T
    boundary::Boundary
end
DatePeriodFrame{T}(; boundary = Begin::Boundary) where {T<:Dates.DatePeriod} =
    DatePeriodFrame(T(1), boundary)
DatePeriodFrame{T}(
    n::Integer;
    boundary = Begin::Boundary,
) where {T<:Dates.DatePeriod} = DatePeriodFrame(T(n), boundary)

"""An identity frame returned by `TimeFrame()` or `TimeFrame(\"\")`."""
struct NoTimeFrame <: TimeFrame
    NoTimeFrame(args...; kwargs...) = new()
end
TimeFrame() = NoTimeFrame()

# Base.hash(tf::TimePeriodFrame, h::UInt) = hash(tf.period, hash(tf.boundary))
# Base.:(==)(tf1::TimePeriodFrame, tf2::TimePeriodFrame) = hash(tf1) == hash(tf2)

function _period_step(::Type{Date})
    Dates.Day(1)
end

const period_step = Dates.Millisecond(1)

function _period_step(::Type{DateTime})
    period_step
end

_period_step(::Type{Dates.Time}) = Dates.Nanosecond(1)

struct Microsecond <: AbstractTimePeriodFrame
    period::Dates.Microsecond
    boundary::Boundary
end
Microsecond(n::Integer = 1) = Microsecond(Dates.Microsecond(n), Begin)

struct Nanosecond <: AbstractTimePeriodFrame
    period::Dates.Nanosecond
    boundary::Boundary
end
Nanosecond(n::Integer = 1) = Nanosecond(Dates.Nanosecond(n), Begin)

struct Millisecond <: AbstractTimePeriodFrame
    period::Dates.Millisecond
    boundary::Boundary
end
Millisecond() = Millisecond(Dates.Millisecond(1), Begin)
Millisecond(n::Integer) = Millisecond(Dates.Millisecond(n), Begin)

struct Second <: AbstractTimePeriodFrame
    period::Dates.Second
    boundary::Boundary
end
Second() = Second(Dates.Second(1), Begin)
Second(n::Integer) = Second(Dates.Second(n), Begin)

struct Minute <: AbstractTimePeriodFrame
    period::Dates.Minute
    boundary::Boundary
end
Minute() = Minute(Dates.Minute(1), Begin)
Minute(n::Integer) = Minute(Dates.Minute(n), Begin)

struct Hour <: AbstractTimePeriodFrame
    period::Dates.Hour
    boundary::Boundary
end
Hour() = Hour(Dates.Hour(1), Begin)
Hour(n::Integer) = Hour(Dates.Hour(n), Begin)

struct Day <: AbstractDatePeriodFrame
    period::Dates.Day
    boundary::Boundary
end
Day() = Day(Dates.Day(1), Begin)
Day(n::Integer) = Day(Dates.Day(n), Begin)

struct Week <: AbstractDatePeriodFrame
    period::Dates.Week
    boundary::Boundary
    firstdayofweek::Int
    function Week(
        period::Dates.Week,
        boundary::Boundary,
        firstdayofweek::Integer = 1,
    )
        1 <= firstdayofweek <= 7 || throw(
            ArgumentError(
                "firstdayofweek must be between 1 (Monday) and 7 (Sunday)",
            ),
        )
        new(period, boundary, firstdayofweek)
    end
end
Week() = Week(Dates.Week(1), Begin)
Week(n::Integer) = Week(Dates.Week(n), Begin)

"""`MonthEnd(n=1)` constructs an end-boundary frame of `n` months."""
struct MonthEnd <: AbstractDatePeriodFrame
    period::Dates.Month
    boundary::Boundary
end
MonthEnd() = MonthEnd(Dates.Month(1), End)
MonthEnd(n::Integer) = MonthEnd(Dates.Month(n), End)

"""`MonthBegin(n=1)` constructs a beginning-boundary frame of `n` months."""
struct MonthBegin <: AbstractDatePeriodFrame
    period::Dates.Month
    boundary::Boundary
end
MonthBegin() = MonthBegin(Dates.Month(1), Begin)
MonthBegin(n::Integer) = MonthBegin(Dates.Month(n), Begin)

"""`YearEnd(n=1)` constructs an end-boundary frame of `n` years."""
struct YearEnd <: AbstractDatePeriodFrame
    period::Dates.Year
    boundary::Boundary
end
YearEnd() = YearEnd(Dates.Year(1), End)
YearEnd(n::Integer) = YearEnd(Dates.Year(n), End)

"""`YearBegin(n=1)` constructs a beginning-boundary frame of `n` years."""
struct YearBegin <: AbstractDatePeriodFrame
    period::Dates.Year
    boundary::Boundary
end
YearBegin() = YearBegin(Dates.Year(1), Begin)
YearBegin(n::Integer) = YearBegin(Dates.Year(n), Begin)

"""
    BusinessMonthBegin(n=1)

Group by the first weekday of each month bucket. Weekends are Saturday and
Sunday; public holidays are not excluded.
"""
struct BusinessMonthBegin <: AbstractDatePeriodFrame
    period::Dates.Month
    boundary::Boundary
end
BusinessMonthBegin(n::Integer = 1) = BusinessMonthBegin(Dates.Month(n), Begin)

"""
    BusinessMonthEnd(n=1)

Group by the last weekday of each month bucket. Weekends are Saturday and
Sunday; public holidays are not excluded.
"""
struct BusinessMonthEnd <: AbstractDatePeriodFrame
    period::Dates.Month
    boundary::Boundary
end
BusinessMonthEnd(n::Integer = 1) = BusinessMonthEnd(Dates.Month(n), End)

const BusinessMonthFrame = Union{BusinessMonthBegin,BusinessMonthEnd}

const _D_STR2TIMEFRAME = Dict(
    "A"=>YearEnd,
    "AS"=>YearBegin,
    "M"=>MonthEnd,
    "MS"=>MonthBegin,
    "BM"=>BusinessMonthEnd,
    "BMS"=>BusinessMonthBegin,
    "W"=>Week,
    "D"=>Day,
    "H"=>Hour,
    "T"=>Minute,
    "S"=>Second,
    "L"=>Millisecond,
    "U"=>Microsecond,
    "N"=>Nanosecond,
    "" => NoTimeFrame,
)
# Reverse key/value
const _D_TIMEFRAME2STR = Dict{DataType,String}()
for (key, typ) in _D_STR2TIMEFRAME
    _D_TIMEFRAME2STR[typ] = key
end
# Additional shortcuts
const _D_STR2TIMEFRAME_ADDITIONAL =
    Dict("MIN"=>Minute, "US"=>Microsecond, "NS"=>Nanosecond)
for (key, value) in _D_STR2TIMEFRAME_ADDITIONAL
    _D_STR2TIMEFRAME[key] = value
end

# To string
function Base.String(tf::AbstractPeriodFrame)
    s_tf = _D_TIMEFRAME2STR[typeof(tf)]
    if tf.period.value == 1
        s_tf
    else
        "$(tf.period.value)$(s_tf)"
    end
end

Base.String(::NoTimeFrame) = ""

# Parse
function TimeFrame(
    s::AbstractString;
    boundary = UndefBoundary,
    firstdayofweek = nothing,
)
    boundary isa Boundary ||
        throw(ArgumentError("boundary must be a Boundary value"))
    isempty(s) && return NoTimeFrame()
    m = match(r"\A([0-9]*)(BMS|BM|AS|MS|MIN|US|NS|A|M|W|D|H|T|S|L|U|N)\z"i, s)
    isnothing(m) && throw(ArgumentError("Can't parse '$s' to TimeFrame"))
    value = isempty(m[1]) ? 1 : tryparse(Int, m[1])
    (isnothing(value) || value <= 0) &&
        throw(ArgumentError("TimeFrame magnitude must be a positive Int"))
    unit = m[2] == "ms" ? "L" : uppercase(m[2])
    tf = _D_STR2TIMEFRAME[unit](value)
    if !isnothing(firstdayofweek)
        tf isa Week || throw(
            ArgumentError("firstdayofweek is only supported for weekly frames"),
        )
        firstdayofweek isa Integer ||
            throw(ArgumentError("firstdayofweek must be an integer"))
        tf = Week(tf.period, tf.boundary, firstdayofweek)
    end
    boundary == UndefBoundary ? tf : _with_boundary(tf, boundary)
end

_with_boundary(tf::AbstractPeriodFrame, boundary) =
    typeof(tf)(tf.period, boundary)
_with_boundary(tf::Week, boundary) =
    Week(tf.period, boundary, tf.firstdayofweek)

_bucket_start(tf::AbstractPeriodFrame, dt) = floor(dt, tf.period)

_time_nanoseconds(dt::Dates.Time) = Int128(Dates.value(dt))

function _round_subday(tf::AbstractTimePeriodFrame, dt, boundary)
    width = Dates.value(convert(Dates.Nanosecond, tf.period))
    width > 0 || throw(ArgumentError("period must be positive"))
    remainder = mod(_time_nanoseconds(dt), width)
    offset = -remainder
    if boundary == End
        offset += iszero(remainder) ? 0 : width
        offset -= Dates.value(_period_step(typeof(dt)))
    elseif boundary != Begin
        throw(ArgumentError("unsupported boundary"))
    end
    dt + Dates.Nanosecond(offset)
end

_bucket_start(tf::AbstractTimePeriodFrame, dt::Dates.Time) =
    _round_subday(tf, dt, Begin)
function _bucket_start(tf::Week, dt)
    shift = Dates.Day(tf.firstdayofweek - 1)
    floor(dt - shift, tf.period) + shift
end

function _bucket_label(tf::AbstractPeriodFrame, start, ::Type{T}) where {T}
    start = convert(T, start)
    tf.boundary == Begin ? start : start + tf.period - _period_step(T)
end

function _bucket_label(tf::BusinessMonthFrame, start, ::Type{T}) where {T}
    label =
        tf.boundary == Begin ? convert(T, start) :
        convert(T, start + tf.period) - _period_step(T)
    weekday = Dates.dayofweek(label)
    if weekday > 5
        label += Dates.Day(tf.boundary == Begin ? 8 - weekday : 5 - weekday)
    end
    label
end

# grouper
function dt_grouper(tf::AbstractPeriodFrame)
    dt -> _d_f_boundary[tf.boundary](dt, tf.period)
end

function dt_grouper(tf::AbstractPeriodFrame, t::Type)
    if tf.boundary == Begin
        dt -> _d_f_boundary[tf.boundary](dt, tf.period)
    elseif tf.boundary == End
        dt -> _d_f_boundary[tf.boundary](dt, tf.period) - _period_step(t)
    else
        error("Unsupported boundary $(tf.boundary)")
    end
end

struct CustomTimeFrame <: TimeFrame
    f_group::Function
end

function TimeFrame(f_group::Function)
    CustomTimeFrame(f_group)
end

function TimeFrame(td::Dates.TimePeriod; boundary = Begin::Boundary)
    T = typeof(td)
    TimePeriodFrame{T}(td.value, boundary = boundary)
end

function TimeFrame(td::Dates.DatePeriod; boundary = Begin::Boundary)
    T = typeof(td)
    DatePeriodFrame{T}(td.value, boundary = boundary)
end

function dt_grouper(tf::CustomTimeFrame, ::Type)
    tf.f_group
end

const _d_f_boundary = Dict(Begin::Boundary => floor, End::Boundary => ceil)

"""
    apply(tf::TimeFrame, dt)

Return the bucket boundary for `dt`. Beginning frames round down; end frames
round up and subtract the input type's smallest supported step. Identity frames
return `dt` unchanged. Custom frames call their grouping function.
"""
function apply(tf::TimeFrame, dt)
    dt_grouper(tf, typeof(dt))(dt)
end

apply(::NoTimeFrame, dt) = dt

apply(tf::AbstractTimePeriodFrame, dt::Dates.Time) =
    _round_subday(tf, dt, tf.boundary)

function apply(tf::Week, dt::Dates.TimeType)
    start = _bucket_start(tf, dt)
    tf.boundary == Begin && return start
    ceiling = dt == start ? start : start + tf.period
    ceiling - _period_step(typeof(dt))
end

apply(tf::BusinessMonthFrame, dt::Dates.TimeType) =
    _bucket_label(tf, _bucket_start(tf, dt), typeof(dt))

"""
    TimeFrames.tonext(tf::AbstractPeriodFrame, dt::Dates.TimeType; same=false)

Return the next bucket label after `dt`. Set `same=true` to include an existing
label equal to `dt`. Calendar boundaries are recomputed for each bucket, so
month ends do not drift. Use this qualified name to distinguish Dates.tonext.
"""
function tonext(tf::AbstractPeriodFrame, dt::Dates.TimeType; same = false)
    Dates.value(tf.period) > 0 ||
        throw(ArgumentError("period must be positive"))
    start = _bucket_start(tf, dt)
    label = _bucket_label(tf, start, typeof(dt))
    if label < dt || (!same && label == dt)
        label = _bucket_label(tf, start + tf.period, typeof(dt))
    end
    label
end

"""
    date_range(start::T, tf::AbstractPeriodFrame, stop::T; normalize=false)

Return a vector of time values in the inclusive interval `start` to `stop`.
Month, year, week, business-month, and end-boundary frames align to bucket
labels. Other frames preserve the start's offset unless `normalize=true`.
DateTime end labels include the day's final millisecond. This is a bucket API,
not a complete implementation of pandas offsets or holiday calendars.
"""
function date_range(
    start::T,
    tf::AbstractPeriodFrame,
    stop::T;
    normalize = false,
) where {T<:Union{Date,DateTime}}
    Dates.value(tf.period) > 0 ||
        throw(ArgumentError("period must be positive"))
    _arithmetic_period(tf.period, T)
    values = T[]
    start > stop && return values
    aligned =
        normalize ||
        tf.boundary == End ||
        tf.period isa Union{Dates.Month,Dates.Year,Dates.Week}
    if !aligned
        return collect(start:tf.period:stop)
    end
    bucket = _bucket_start(tf, start)
    label = _bucket_label(tf, bucket, T)
    while label < start
        bucket += tf.period
        label = _bucket_label(tf, bucket, T)
    end
    while label <= stop
        push!(values, label)
        bucket += tf.period
        label = _bucket_label(tf, bucket, T)
    end
    values
end

function range(
    start::Dates.TimeType,
    tf::AbstractPeriodFrame;
    stop = nothing,
    length = nothing,
    apply_tf = true,
)
    isnothing(stop) == isnothing(length) &&
        throw(ArgumentError("provide exactly one of stop or length"))
    if !isnothing(length)
        return range(start, tf, length)
    end
    apply_tf ? date_range(start, tf, stop) : start:tf:stop
end

# range
Base.:(:)(
    start::Dates.TimeType,
    tf::AbstractPeriodFrame,
    stop::Dates.TimeType,
) = start:_arithmetic_period(tf.period, typeof(start)):stop

"""
    range(start::Dates.TimeType, tf::AbstractPeriodFrame, stop::Dates.TimeType; apply_tf=true)
    range(start::Dates.TimeType, tf::AbstractPeriodFrame, length::Integer)
    range(tf::AbstractPeriodFrame, stop::Dates.TimeType, length::Integer)
    range(start::Dates.TimeType, tf::AbstractPeriodFrame; stop, length, apply_tf=true)

Construct a range with the frame's period as step. The two-endpoint form excludes
`stop` and rounds endpoints by default. Set `apply_tf=false` to retain the starting
offset. Length-based forms retain offsets; the backwards form excludes `stop`.
The keyword form requires exactly one of `stop` or `length`. Its stop is
inclusive and calendar frames align to bucket labels through [`date_range`](@ref).
Set `apply_tf=false` to use an inclusive Dates range without alignment.
"""
function range(
    dt1::Dates.TimeType,
    tf::AbstractPeriodFrame,
    dt2::Dates.TimeType;
    apply_tf = true,
)
    td = _period_step(typeof(dt2))
    period = _arithmetic_period(tf.period, typeof(dt1))
    if apply_tf
        apply(tf, dt1):period:apply(tf, dt2-td)
    else
        dt1:period:(dt2-td)
    end
end

function range(dt1::Dates.TimeType, tf::AbstractPeriodFrame, len::Integer)
    range(dt1, step = _arithmetic_period(tf.period, typeof(dt1)), length = len)
end

function range(tf::AbstractPeriodFrame, dt2::Dates.TimeType, len::Integer)
    period = _arithmetic_period(tf.period, typeof(dt2))
    range(dt2 - len * period, step = period, length = len)
end

range(dt1::DateTime, tf::NoTimeFrame, dt2::DateTime) = [dt1]

"""`tf\"15T\"` constructs a frame using the same syntax as `TimeFrame(\"15T\")`."""
macro tf_str(tf)
    :(TimeFrame($tf))
end

promote_timetype(::Type{DateTime}, ::Type) = DateTime

promote_timetype(::Type{Date}, ::Type) = Date
promote_timetype(::Type{Date}, ::Type{<:AbstractTimePeriodFrame}) = DateTime
promote_timetype(::Type{Date}, ::Type{Hour}) = DateTime
promote_timetype(::Type{Date}, ::Type{Minute}) = DateTime
promote_timetype(::Type{Date}, ::Type{Second}) = DateTime
promote_timetype(::Type{Date}, ::Type{Millisecond}) = DateTime

promote_timetype(::Type{Dates.Time}, ::Type) = Dates.Time
promote_timetype(::Type{Dates.Time}, ::Type{<:AbstractDatePeriodFrame}) =
    throw(InexactError(:none, Any, nothing))
promote_timetype(::Type{Dates.Time}, ::Type{YearBegin}) =
    throw(InexactError(:none, Any, nothing))
promote_timetype(::Type{Dates.Time}, ::Type{YearEnd}) =
    throw(InexactError(:none, Any, nothing))
promote_timetype(::Type{Dates.Time}, ::Type{MonthBegin}) =
    throw(InexactError(:none, Any, nothing))
promote_timetype(::Type{Dates.Time}, ::Type{MonthEnd}) =
    throw(InexactError(:none, Any, nothing))
promote_timetype(::Type{Dates.Time}, ::Type{Week}) =
    throw(InexactError(:none, Any, nothing))
promote_timetype(::Type{Dates.Time}, ::Type{Day}) =
    throw(InexactError(:none, Any, nothing))

_arithmetic_period(period, ::Type) = period
_arithmetic_period(
    period::Union{Dates.Microsecond,Dates.Nanosecond},
    ::Type{DateTime},
) = convert(Dates.Millisecond, period)

function +(t::T, tf::TF) where {T<:Dates.TimeType,TF<:TimeFrame}
    promoted = convert(promote_timetype(T, TF), t)
    promoted + _arithmetic_period(tf.period, typeof(promoted))
end

+(tf::TimeFrame, t::TimeType) = t + tf

function -(t::T, tf::TF) where {T<:Dates.TimeType,TF<:TimeFrame}
    promoted = convert(promote_timetype(T, TF), t)
    promoted - _arithmetic_period(tf.period, typeof(promoted))
end


*(tf::AbstractPeriodFrame, n::Int) = typeof(tf)(tf.period * n, tf.boundary)
*(n::Int, tf::AbstractPeriodFrame) = *(tf, n)
*(tf::Week, n::Int) = Week(tf.period * n, tf.boundary, tf.firstdayofweek)


end # module
