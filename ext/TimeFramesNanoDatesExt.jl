module TimeFramesNanoDatesExt

using Dates
using NanoDates: NanoDate
import TimeFrames

TimeFrames._period_step(::Type{NanoDate}) = Dates.Nanosecond(1)
TimeFrames.promote_timetype(::Type{NanoDate}, ::Type) = NanoDate

function TimeFrames._time_nanoseconds(dt::NanoDate)
    milliseconds = Int128(Dates.value(DateTime(dt))) - Dates.value(DateTime(0))
    milliseconds * 1_000_000 + mod(Dates.value(Dates.Time(dt)), 1_000_000)
end

TimeFrames._bucket_start(tf::TimeFrames.AbstractTimePeriodFrame, dt::NanoDate) =
    TimeFrames._round_subday(tf, dt, TimeFrames.Begin)

TimeFrames.apply(tf::TimeFrames.AbstractTimePeriodFrame, dt::NanoDate) =
    TimeFrames._round_subday(tf, dt, tf.boundary)

end
