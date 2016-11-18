module TimeFrames

import Base: range

export TimeFrame, Boundary
export Monthly, Yearly, MonthlyStart, YearlyStart
export Millisecondly, Secondly, Minutely, Hourly, Daily, Weekly
export NoTimeFrame
export apply, range, shortcut
export Begin, End

abstract TimeFrame

@enum(Boundary,
    UndefBoundary = 0,  # Undefined boundary
    Begin = 1,  # begin of interval
    End   = 2,  # end of interval
)

#T should be Dates.TimePeriod

abstract AbstractPeriodFrame <: TimeFrame
abstract AbstractTimePeriodFrame <: AbstractPeriodFrame
abstract AbstractDatePeriodFrame <: AbstractPeriodFrame

immutable TimePeriodFrame{T <: Dates.TimePeriod} <: AbstractTimePeriodFrame
    time_period::T
    boundary::Boundary
    TimePeriodFrame(; boundary=Begin::Boundary) = new(1, boundary)
    TimePeriodFrame(n::Integer; boundary=Begin::Boundary) = new(n, boundary)
end

immutable DatePeriodFrame{T <: Dates.DatePeriod} <: AbstractDatePeriodFrame
    time_period::T
    boundary::Boundary
    DatePeriodFrame(; boundary=Begin::Boundary) = new(1, boundary)
    DatePeriodFrame(n::Integer; boundary=Begin::Boundary) = new(n, boundary)
end


immutable NoTimeFrame <: TimeFrame
    NoTimeFrame(args...; kwargs...) = new()
end

Base.hash(tf::TimePeriodFrame, h::UInt) = hash(tf.time_period, hash(tf.boundary))
Base.:(==)(tf1::TimePeriodFrame, tf2::TimePeriodFrame) = hash(tf1) == hash(tf2)


function period_step(::Type{Date})
    Dates.Day(1)
end

function period_step(::Type{DateTime})
    Dates.Millisecond(1)
end

immutable Millisecondly <: AbstractTimePeriodFrame
    time_period::Dates.TimePeriod
    boundary::Boundary
    Millisecondly() = new(Dates.Millisecond(1), Begin)
    Millisecondly(n::Integer) = new(Dates.Millisecond(n), Begin)
end

immutable Secondly <: AbstractTimePeriodFrame
    time_period::Dates.TimePeriod
    boundary::Boundary
    Secondly() = new(Dates.Second(1), Begin)
    Secondly(n::Integer) = new(Dates.Second(n), Begin)
end

immutable Minutely <: AbstractTimePeriodFrame
    time_period::Dates.TimePeriod
    boundary::Boundary
    Minutely() = new(Dates.Minute(1), Begin)
    Minutely(n::Integer) = new(Dates.Minute(n), Begin)
end

immutable Hourly <: AbstractTimePeriodFrame
    time_period::Dates.TimePeriod
    boundary::Boundary
    Hourly() = new(Dates.Hour(1), Begin)
    Hourly(n::Integer) = new(Dates.Hour(n), Begin)
end

immutable Daily <: AbstractDatePeriodFrame
    time_period::Dates.DatePeriod
    boundary::Boundary
    Daily() = new(Dates.Day(1), Begin)
    Daily(n::Integer) = new(Dates.Day(n), Begin)
end

immutable Weekly <: AbstractDatePeriodFrame
    time_period::Dates.DatePeriod
    boundary::Boundary
    Weekly() = new(Dates.Week(1), Begin)
    Weekly(n::Integer) = new(Dates.Week(n), Begin)
end

immutable Monthly <: AbstractDatePeriodFrame
    time_period::Dates.DatePeriod
    boundary::Boundary
    Monthly() = new(Dates.Month(1), End)
    Monthly(n::Integer) = new(Dates.Month(n), End)
end

immutable MonthlyStart <: AbstractDatePeriodFrame
    time_period::Dates.DatePeriod
    boundary::Boundary
    MonthlyStart() = new(Dates.Month(1), Begin)
    MonthlyStart(n::Integer) = new(Dates.Month(n), Begin)
end

immutable Yearly <: AbstractDatePeriodFrame
    time_period::Dates.DatePeriod
    boundary::Boundary
    Yearly() = new(Dates.Year(1), End)
    Yearly(n::Integer) = new(Dates.Year(n), End)
end

immutable YearlyStart <: AbstractDatePeriodFrame
    time_period::Dates.DatePeriod
    boundary::Boundary
    YearlyStart() = new(Dates.Year(1), Begin)
    YearlyStart(n::Integer) = new(Dates.Year(n), Begin)
end

TimeFrame() = Secondly(0)

function dt_grouper(tf::AbstractPeriodFrame)
    dt -> _d_f_boundary[tf.boundary](dt, tf.time_period)
end

function dt_grouper(tf::AbstractPeriodFrame, t::Type)
    if tf.boundary == Begin
        dt -> _d_f_boundary[tf.boundary](dt, tf.time_period)
    elseif tf.boundary == End
        dt -> _d_f_boundary[tf.boundary](dt, tf.time_period) - period_step(t)
    else
        error("Unsupported boundary $(tf.boundary)")
    end
end

_D_STR2TIMEFRAME = Dict(
    "A"=>Yearly,
    "AS"=>YearlyStart,
    "M"=>Monthly,
    "MS"=>MonthlyStart,
    "W"=>Weekly,
    "D"=>Daily,
    "H"=>Hourly,
    "T"=>Minutely,
    "S"=>Secondly,
    "L"=>Millisecondly,
    #"U"=>Microsecondly,
    ""=>NoTimeFrame
)
# Reverse key/value
_D_TIMEFRAME2STR = Dict{DataType,String}()
for (key, typ) in _D_STR2TIMEFRAME
    _D_TIMEFRAME2STR[typ] = key
end
# Additional shortcuts
_D_STR2TIMEFRAME_ADDITIONAL = Dict(
    "MIN"=>Minutely,
)
for (key, value) in _D_STR2TIMEFRAME_ADDITIONAL
    _D_STR2TIMEFRAME[key] = value
end

function shortcut(tf::TimeFrame)
    s_tf = _D_TIMEFRAME2STR[typeof(tf)]
    if tf.time_period.value == 1
        s_tf
    else
        "$(tf.time_period.value)$(s_tf)"
    end
end

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

type CustomTimeFrame <: TimeFrame
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

typealias DateOrDateTime Union{Date,DateTime}

function range(dt1::DateOrDateTime, tf::AbstractPeriodFrame, dt2::DateOrDateTime; apply_tf=true)
    td = period_step(typeof(dt2))
    if apply_tf
        apply(tf, dt1):tf.time_period:apply(tf, dt2-td)
    else
        dt1:tf.time_period:dt2-td
    end
end

function range(dt1::DateOrDateTime, td::Dates.Period, dt2::DateOrDateTime; apply_tf=true)
    range(dt1, TimeFrame(td), dt2; apply_tf=apply_tf)
end

function range(dt1::DateOrDateTime, tf::AbstractPeriodFrame, len::Integer)
    range(dt1, tf.time_period, len)
end

function range(tf::AbstractPeriodFrame, dt2::DateOrDateTime, len::Integer)
    range(dt2 - len * tf.time_period, tf.time_period, len)
end

function range(td::Dates.Period, dt2::DateOrDateTime, len::Integer)
    range(TimeFrame(td), dt2, len)
end

end # module
