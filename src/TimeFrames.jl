module TimeFrames

import Base: range, +, -, *

using Dates

export TimeFrame, Boundary
export YearBegin, YearEnd
export MonthBegin, MonthEnd
# export Millisecond, Second, Minute, Hour, Day, Week
export NoTimeFrame
export apply, range
export Begin, End
export @tf_str

"""
    TimeFrame(frequency::AbstractString; boundary=TimeFrames.UndefBoundary)
    TimeFrame(period::Dates.Period; boundary=Begin)
    TimeFrame(grouper::Function)
    TimeFrame()

Construct a time bucket from a frequency, a Dates period, or a custom grouping
function. An empty string or no argument creates an identity frame.

Supported frequency units are `A`, `AS`, `M`, `MS`, `W`, `D`, `H`, `T` (or
`MIN`), `S`, and `L` (or lowercase `ms`). Units are case insensitive except
that `ms` means milliseconds and `MS` means month start. Units may have a positive integer
prefix. `A` and `M` default to `End`; other units default to `Begin`.
Invalid strings throw `ArgumentError`.
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

#struct Microsecond <: AbstractTimePeriodFrame
#    period::Dates.TimePeriod
#    boundary::Boundary
#end
#Microsecond() = Microsecond(Dates.Microsecond(1), Begin)
#Microsecond(n::Integer) = Microsecond(Dates.Microsecond(n), Begin)

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

const _D_STR2TIMEFRAME = Dict(
    "A"=>YearEnd,
    "AS"=>YearBegin,
    "M"=>MonthEnd,
    "MS"=>MonthBegin,
    "W"=>Week,
    "D"=>Day,
    "H"=>Hour,
    "T"=>Minute,
    "S"=>Second,
    "L"=>Millisecond,
    #"U"=>Microsecond,
    "" => NoTimeFrame,
)
# Reverse key/value
const _D_TIMEFRAME2STR = Dict{DataType,String}()
for (key, typ) in _D_STR2TIMEFRAME
    _D_TIMEFRAME2STR[typ] = key
end
# Additional shortcuts
const _D_STR2TIMEFRAME_ADDITIONAL = Dict("MIN"=>Minute)
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
function TimeFrame(s::AbstractString; boundary = UndefBoundary)
    boundary isa Boundary ||
        throw(ArgumentError("boundary must be a Boundary value"))
    isempty(s) && return NoTimeFrame()
    m = match(r"\A([0-9]*)(AS|MS|MIN|A|M|W|D|H|T|S|L)\z"i, s)
    isnothing(m) && throw(ArgumentError("Can't parse '$s' to TimeFrame"))
    value = isempty(m[1]) ? 1 : tryparse(Int, m[1])
    (isnothing(value) || value <= 0) &&
        throw(ArgumentError("TimeFrame magnitude must be a positive Int"))
    unit = m[2] == "ms" ? "L" : uppercase(m[2])
    tf = _D_STR2TIMEFRAME[unit](value)
    boundary == UndefBoundary ? tf : typeof(tf)(tf.period, boundary)
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

function tonext(tf::TimeFrame, dt::Dates.TimeType; same = false)
    dt2 = apply(tf, dt)
    if dt2 < dt
        dt2 + tf
    else
        if !same && dt2 == dt
            dt2 + tf
        else
            dt2
        end
    end
end

# range
Base.:(:)(
    start::Dates.TimeType,
    tf::AbstractPeriodFrame,
    stop::Dates.TimeType,
) = start:tf.period:stop

"""
    range(start::Dates.TimeType, tf::AbstractPeriodFrame, stop::Dates.TimeType; apply_tf=true)
    range(start::Dates.TimeType, tf::AbstractPeriodFrame, length::Integer)
    range(tf::AbstractPeriodFrame, stop::Dates.TimeType, length::Integer)

Construct a range with the frame's period as step. The two-endpoint form excludes
`stop` and rounds endpoints by default. Set `apply_tf=false` to retain the starting
offset. Length-based forms retain offsets; the backwards form excludes `stop`.
"""
function range(
    dt1::Dates.TimeType,
    tf::AbstractPeriodFrame,
    dt2::Dates.TimeType;
    apply_tf = true,
)
    td = _period_step(typeof(dt2))
    if apply_tf
        apply(tf, dt1):tf.period:apply(tf, dt2-td)
    else
        dt1:tf.period:(dt2-td)
    end
end

function range(dt1::Dates.TimeType, tf::AbstractPeriodFrame, len::Integer)
    range(dt1, step = tf.period, length = len)
end

function range(tf::AbstractPeriodFrame, dt2::Dates.TimeType, len::Integer)
    range(dt2 - len * tf.period, step = tf.period, length = len)
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

+(t::T, tf::TF) where {T<:Dates.TimeType,TF<:TimeFrame} =
    convert(promote_timetype(T, TF), t) + tf.period

+(tf::TimeFrame, t::TimeType) = t + tf

-(t::T, tf::TF) where {T<:Dates.TimeType,TF<:TimeFrame} =
    convert(promote_timetype(T, TF), t) - tf.period


*(tf::AbstractPeriodFrame, n::Int) = typeof(tf)(tf.period * n, tf.boundary)
*(n::Int, tf::AbstractPeriodFrame) = *(tf, n)


end # module
