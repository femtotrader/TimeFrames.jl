module TimeFrames

using Base: Dates

abstract AbstractTimeFrame

@enum(Boundary,
    Begin = 1,  # begin of interval
    End   = 2,  # end of interval
)

#T should be Dates.TimePeriod
type TimeFrame{T} <: AbstractTimeFrame
    time_period::T
    boundary::Boundary
    TimeFrame(; boundary=Begin::Boundary) = new(1, boundary)
    TimeFrame(n::Integer; boundary=Begin::Boundary) = new(n, boundary)
end

Base.hash(tf::AbstractTimeFrame, h::UInt) = hash(tf.val)
Base.:(==)(tf1::AbstractTimeFrame, tf2::AbstractTimeFrame) = isequal(tf1.time_period, tf2.time_period)

Millisecondly = TimeFrame{Dates.Millisecond}
Secondly = TimeFrame{Dates.Second}
Minutely = TimeFrame{Dates.Minute}
Hourly = TimeFrame{Dates.Hour}
Daily = TimeFrame{Dates.Day}
Weekly = TimeFrame{Dates.Week}
Monthly = TimeFrame{Dates.Month}
Yearly = TimeFrame{Dates.Year}

TimeFrame() = Secondly(0)

_D_TIMEFRAME2STR = Dict(
    Yearly=>"Y",
    Monthly=>"M",
    Weekly=>"W",
    Daily=>"D",
    Hourly=>"H",
    Minutely=>"T"
)

_D_STR2TIMEFRAME = Dict{String,DataType}()
for (key, value) in _D_TIMEFRAME2STR
    _D_STR2TIMEFRAME[value] = key
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

_d_f_boundary = Dict(
    Begin::Boundary => floor,
    End::Boundary => ceil
)

function grouper(tf)
    dt -> _d_f_boundary[tf.boundary](dt, tf.time_period)
end


end # module
