module TimeFrames

using Base: Dates

export TimeFrame, Boundary
export Millisecondly, Secondly, Minutely, Hourly, Daily, Weekly, Monthly, Yearly
export apply
export Begin, End

abstract TimeFrame

@enum(Boundary,
    UndefBoundary = 0,  # Undefined boundary
    Begin = 1,  # begin of interval
    End   = 2,  # end of interval
)

#T should be Dates.TimePeriod
immutable TimePeriodFrame{T} <: TimeFrame
    time_period::T
    boundary::Boundary
    TimePeriodFrame(; boundary=Begin::Boundary) = new(1, boundary)
    TimePeriodFrame(n::Integer; boundary=Begin::Boundary) = new(n, boundary)
end

Base.hash(tf::TimePeriodFrame, h::UInt) = hash(tf.time_period, hash(tf.boundary))
Base.:(==)(tf1::TimePeriodFrame, tf2::TimePeriodFrame) = hash(tf1) == hash(tf2)

DATE_PERIOD_STEP = Day(1)
TIME_PERIOD_STEP = Millisecond(1)

Millisecondly = TimePeriodFrame{Dates.Millisecond}
Secondly = TimePeriodFrame{Dates.Second}
Minutely = TimePeriodFrame{Dates.Minute}
Hourly = TimePeriodFrame{Dates.Hour}
Daily = TimePeriodFrame{Dates.Day}
Weekly = TimePeriodFrame{Dates.Week}
Monthly = TimePeriodFrame{Dates.Month}
Yearly = TimePeriodFrame{Dates.Year}

TimeFrame() = Secondly(0)

function dt_grouper(tf::TimePeriodFrame)
    dt -> _d_f_boundary[tf.boundary](dt, tf.time_period)
end

function dt_grouper(tf::TimePeriodFrame, ::Type{Date})
    if tf.boundary == Begin
        dt -> _d_f_boundary[tf.boundary](dt, tf.time_period)
    elseif tf.boundary == End
        dt -> _d_f_boundary[tf.boundary](dt, tf.time_period) - DATE_PERIOD_STEP
    else
        error("Unsupported boundary $(tf.boundary)")
    end
end

function dt_grouper(tf::TimePeriodFrame, ::Type{DateTime})
    if tf.boundary == Begin
        dt -> _d_f_boundary[tf.boundary](dt, tf.time_period)
    elseif tf.boundary == End
        dt -> _d_f_boundary[tf.boundary](dt, tf.time_period) - TIME_PERIOD_STEP
    else
        error("Unsupported boundary $(tf.boundary)")
    end
end

_D_STR2TIMEFRAME = Dict(
    "Y"=>Yearly,
    "M"=>Monthly,
    "W"=>Weekly,
    "D"=>Daily,
    "H"=>Hourly,
    "T"=>Minutely,
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

function TimeFrame(td::Dates.Period; boundary=Begin::Boundary)
    T = typeof(td)
    TimePeriodFrame{T}(td.value, boundary=boundary)
end

function dt_grouper(tf::CustomTimeFrame, ::Type)
    tf.f_group
end

_d_f_boundary = Dict(
    Begin::Boundary => floor,
    End::Boundary => ceil
)

function apply(tf, dt)
    dt_grouper(tf, typeof(dt))(dt)
end


end # module
