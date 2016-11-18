module TimeFrames

using Base: Dates
import Base: range

export TimeFrame, Boundary
export Millisecondly, Secondly, Minutely, Hourly, Daily, Weekly, Monthly, Yearly
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

abstract PeriodFrame <: TimeFrame


immutable TimePeriodFrame{T <: TimePeriod} <: PeriodFrame
    time_period::T
    boundary::Boundary
    TimePeriodFrame(; boundary=Begin::Boundary) = new(1, boundary)
    TimePeriodFrame(n::Integer; boundary=Begin::Boundary) = new(n, boundary)
end

immutable DatePeriodFrame{T <: DatePeriod} <: PeriodFrame
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
    Day(1)
end

function period_step(::Type{DateTime})
    Millisecond(1)
end

Millisecondly = TimePeriodFrame{Dates.Millisecond}
Secondly = TimePeriodFrame{Dates.Second}
Minutely = TimePeriodFrame{Dates.Minute}
Hourly = TimePeriodFrame{Dates.Hour}
Daily = DatePeriodFrame{Dates.Day}
Weekly = DatePeriodFrame{Dates.Week}
Monthly = DatePeriodFrame{Dates.Month}
Yearly = DatePeriodFrame{Dates.Year}

TimeFrame() = Secondly(0)

function dt_grouper(tf::PeriodFrame)
    dt -> _d_f_boundary[tf.boundary](dt, tf.time_period)
end

function dt_grouper(tf::PeriodFrame, t::Type)
    if tf.boundary == Begin
        dt -> _d_f_boundary[tf.boundary](dt, tf.time_period)
    elseif tf.boundary == End
        dt -> _d_f_boundary[tf.boundary](dt, tf.time_period) - period_step(t)
    else
        error("Unsupported boundary $(tf.boundary)")
    end
end

_D_STR2TIMEFRAME = Dict(
    "Y"=>Yearly,  # may be named Annually
    "M"=>Monthly,
    "W"=>Weekly,
    "D"=>Daily,
    "H"=>Hourly,
    "T"=>Minutely,
    ""=>NoTimeFrame
)
# Reverse key/value
_D_TIMEFRAME2STR = Dict{DataType,String}()
for (key, value) in _D_STR2TIMEFRAME
    _D_TIMEFRAME2STR[value] = key
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
        if boundary == UndefBoundary
            tf_typ(value)
        else
            tf_typ(value, boundary=boundary)
        end
    end
end

type CustomTimeFrame <: TimeFrame
    f_group::Function
end

function TimeFrame(f_group::Function)
    CustomTimeFrame(f_group)
end

function TimeFrame(td::TimePeriod; boundary=Begin::Boundary)
    T = typeof(td)
    TimePeriodFrame{T}(td.value, boundary=boundary)
end

function TimeFrame(td::DatePeriod; boundary=Begin::Boundary)
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

function range(dt1::DateOrDateTime, tf::PeriodFrame, dt2::DateOrDateTime; apply_tf=true)
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

function range(dt1::DateOrDateTime, tf::PeriodFrame, len::Integer)
    range(dt1, tf.time_period, len)
end

function range(tf::PeriodFrame, dt2::DateOrDateTime, len::Integer)
    range(dt2 - len * tf.time_period, tf.time_period, len)
end

function range(td::Dates.Period, dt2::DateOrDateTime, len::Integer)
    range(TimeFrame(td), dt2, len)
end

end # module
