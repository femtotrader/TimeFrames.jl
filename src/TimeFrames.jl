module TimeFrames

import Base: range, +

using Base.Dates: TimeType

export TimeFrame, Boundary
export YearBegin, YearEnd
export MonthBegin, MonthEnd
export Millisecond, Second, Minute, Hour, Day, Week
export NoTimeFrame
export apply, range
export Begin, End
export @tf_str

abstract type TimeFrame end

@enum(Boundary,
    UndefBoundary = 0,  # Undefined boundary
    Begin = 1,  # begin of interval
    End   = 2,  # end of interval
)

#T should be Dates.TimePeriod

abstract type AbstractPeriodFrame <: TimeFrame end
abstract type AbstractTimePeriodFrame <: AbstractPeriodFrame end
abstract type AbstractDatePeriodFrame <: AbstractPeriodFrame end

struct TimePeriodFrame{T <: Dates.TimePeriod} <: AbstractTimePeriodFrame
    period::T
    boundary::Boundary
    TimePeriodFrame{T}(; boundary=Begin::Boundary) where T<:Dates.TimePeriod = new(T(1), boundary)
    TimePeriodFrame{T}(n::Integer; boundary=Begin::Boundary) where T<:Dates.TimePeriod = new(T(n), boundary)
end

struct DatePeriodFrame{T <: Dates.DatePeriod} <: AbstractDatePeriodFrame
    period::T
    boundary::Boundary
    DatePeriodFrame{T}(; boundary=Begin::Boundary) where T<:Dates.DatePeriod = new(T(1), boundary)
    DatePeriodFrame{T}(n::Integer; boundary=Begin::Boundary) where T<:Dates.DatePeriod = new(T(n), boundary)
end

struct NoTimeFrame <: TimeFrame
    NoTimeFrame(args...; kwargs...) = new()
end
TimeFrame() = NoTimeFrame()

# Base.hash(tf::TimePeriodFrame, h::UInt) = hash(tf.period, hash(tf.boundary))
# Base.:(==)(tf1::TimePeriodFrame, tf2::TimePeriodFrame) = hash(tf1) == hash(tf2)

function _period_step(::Type{Date})
    Dates.Day(1)
end

function _period_step(::Type{DateTime})
    Dates.Millisecond(1)
end

struct Millisecond <: AbstractTimePeriodFrame
    period::Dates.TimePeriod
    boundary::Boundary
    Millisecond() = new(Dates.Millisecond(1), Begin)
    Millisecond(n::Integer) = new(Dates.Millisecond(n), Begin)
end

struct Second <: AbstractTimePeriodFrame
    period::Dates.TimePeriod
    boundary::Boundary
    Second() = new(Dates.Second(1), Begin)
    Second(n::Integer) = new(Dates.Second(n), Begin)
end

struct Minute <: AbstractTimePeriodFrame
    period::Dates.TimePeriod
    boundary::Boundary
    Minute() = new(Dates.Minute(1), Begin)
    Minute(n::Integer) = new(Dates.Minute(n), Begin)
end

struct Hour <: AbstractTimePeriodFrame
    period::Dates.TimePeriod
    boundary::Boundary
    Hour() = new(Dates.Hour(1), Begin)
    Hour(n::Integer) = new(Dates.Hour(n), Begin)
end

struct Day <: AbstractDatePeriodFrame
    period::Dates.DatePeriod
    boundary::Boundary
    Day() = new(Dates.Day(1), Begin)
    Day(n::Integer) = new(Dates.Day(n), Begin)
end

struct Week <: AbstractDatePeriodFrame
    period::Dates.DatePeriod
    boundary::Boundary
    Week() = new(Dates.Week(1), Begin)
    Week(n::Integer) = new(Dates.Week(n), Begin)
end

struct MonthEnd <: AbstractDatePeriodFrame
    period::Dates.DatePeriod
    boundary::Boundary
    MonthEnd() = new(Dates.Month(1), End)
    MonthEnd(n::Integer) = new(Dates.Month(n), End)
end

struct MonthBegin <: AbstractDatePeriodFrame
    period::Dates.DatePeriod
    boundary::Boundary
    MonthBegin() = new(Dates.Month(1), Begin)
    MonthBegin(n::Integer) = new(Dates.Month(n), Begin)
end

struct YearEnd <: AbstractDatePeriodFrame
    period::Dates.DatePeriod
    boundary::Boundary
    YearEnd() = new(Dates.Year(1), End)
    YearEnd(n::Integer) = new(Dates.Year(n), End)
end

struct YearBegin <: AbstractDatePeriodFrame
    period::Dates.DatePeriod
    boundary::Boundary
    YearBegin() = new(Dates.Year(1), Begin)
    YearBegin(n::Integer) = new(Dates.Year(n), Begin)
end

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
    ""=>NoTimeFrame
)
# Reverse key/value
const _D_TIMEFRAME2STR = Dict{DataType,String}()
for (key, typ) in _D_STR2TIMEFRAME
    _D_TIMEFRAME2STR[typ] = key
end
# Additional shortcuts
const _D_STR2TIMEFRAME_ADDITIONAL = Dict(
    "MIN"=>Minute,
)
for (key, value) in _D_STR2TIMEFRAME_ADDITIONAL
    _D_STR2TIMEFRAME[key] = value
end

# To string
function String(tf::TimeFrame)
    s_tf = _D_TIMEFRAME2STR[typeof(tf)]
    if tf.period.value == 1
        s_tf
    else
        "$(tf.period.value)$(s_tf)"
    end
end

# Parse
function TimeFrame(s::String; boundary=UndefBoundary)
    freq_pattern = join(keys(_D_STR2TIMEFRAME), "|")
    #pattern = r"^([\d]*)([Y|M|W|D|H|T])$"
    pattern = Regex("^([\\d]*)([$freq_pattern]*)\$", "i")
    m = match(pattern, s)
    if m == nothing
        error("Can't parse '$s' to TimeFrame")
    else
        s_freq = uppercase(m[2])
        tf_typ = _D_STR2TIMEFRAME[s_freq]
        if m[1] != ""
            value = parse(Int, m[1])
        else
            value = 1
        end
        tf = tf_typ(value)
        if boundary != UndefBoundary
            tf.boundary = boundary
        end
        tf
    end
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

function TimeFrame(td::Dates.TimePeriod; boundary=Begin::Boundary)
    T = typeof(td)
    TimePeriodFrame{T}(td.value, boundary=boundary)
end

function TimeFrame(td::Dates.DatePeriod; boundary=Begin::Boundary)
    T = typeof(td)
    DatePeriodFrame{T}(td.value, boundary=boundary)
end

function dt_grouper(tf::CustomTimeFrame, ::Type)
    tf.f_group
end

_d_f_boundary = Dict(
    Begin::Boundary => floor,
    End::Boundary => ceil
)

function apply(tf::TimeFrame, dt)
    dt_grouper(tf, typeof(dt))(dt)
end

# range
function range(dt1::TimeType, tf::AbstractPeriodFrame, dt2::TimeType; apply_tf=true)
    td = _period_step(typeof(dt2))
    if apply_tf
        apply(tf, dt1):tf.period:apply(tf, dt2-td)
    else
        dt1:tf.period:dt2-td
    end
end

function range(dt1::TimeType, tf::AbstractPeriodFrame, len::Integer)
    range(dt1, tf.period, len)
end

function range(tf::AbstractPeriodFrame, dt2::TimeType, len::Integer)
    range(dt2 - len * tf.period, tf.period, len)
end

range(dt1::DateTime, tf::NoTimeFrame, dt2::DateTime) = [dt1]

macro tf_str(tf)
  :(TimeFrame($tf))
end

promote_timetype(::Type{DateTime}, ::Type) = DateTime

promote_timetype(::Type{Date}, ::Type)              = Date
promote_timetype(::Type{Date}, ::Type{Hour})        = DateTime
promote_timetype(::Type{Date}, ::Type{Minute})      = DateTime
promote_timetype(::Type{Date}, ::Type{Second})      = DateTime
promote_timetype(::Type{Date}, ::Type{Millisecond}) = DateTime

promote_timetype(::Type{Dates.Time}, ::Type)             = Dates.Time
promote_timetype(::Type{Dates.Time}, ::Type{YearBegin})  = throw(InexactError())
promote_timetype(::Type{Dates.Time}, ::Type{YearEnd})    = throw(InexactError())
promote_timetype(::Type{Dates.Time}, ::Type{MonthBegin}) = throw(InexactError())
promote_timetype(::Type{Dates.Time}, ::Type{MonthEnd})   = throw(InexactError())
promote_timetype(::Type{Dates.Time}, ::Type{Week})       = throw(InexactError())
promote_timetype(::Type{Dates.Time}, ::Type{Day})        = throw(InexactError())

+(t::TimeType, tf::TimeFrame) =
  convert(promote_timetype(typeof(t), typeof(tf)), t) + tf.period

end # module
