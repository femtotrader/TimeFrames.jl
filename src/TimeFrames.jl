module TimeFrames

using Base: Dates

export TimeFrame, Boundary
export Millisecondly, Secondly, Minutely, Hourly, Daily, Weekly, Monthly, Yearly
export apply

abstract TimeFrame

@enum(Boundary,
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

Base.hash(tf::TimePeriodFrame, h::UInt) = hash(tf.val)
Base.:(==)(tf1::TimePeriodFrame, tf2::TimePeriodFrame) = isequal(tf1.time_period, tf2.time_period)

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

_D_STR2TIMEFRAME = Dict(
    "Y"=>Yearly,
    "M"=>Monthly,
    "W"=>Weekly,
    "D"=>Daily,
    "H"=>Hourly,
    "T"=>Minutely
)

_D_TIMEFRAME2STR = Dict{DataType,String}()
for (key, value) in _D_STR2TIMEFRAME
    _D_TIMEFRAME2STR[value] = key
end

function shortcut(tf::TimeFrame)
    s_tf = _D_TIMEFRAME2STR[typeof(tf)]
    if tf.time_period.value == 1
        s_tf
    else
        "$(tf.time_period.value)$(s_tf)"
    end
end

function TimeFrame(s::String)
    pattern = r"^([\d]*)([Y|M|W|D|H|T])$"
    m = match(pattern, s)
    if m == nothing
        error("Can't parse %s to TimeFrame")
    else
        tf_typ = _D_STR2TIMEFRAME[m[2]]
        value = parse(Int, m[1])
        tf_typ(value)
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


function dt_grouper(tf::CustomTimeFrame)
    tf.f_group
end


_d_f_boundary = Dict(
    Begin::Boundary => floor,
    End::Boundary => ceil
)

function apply(tf, dt)
    dt_grouper(tf)(dt)
end

end # module
