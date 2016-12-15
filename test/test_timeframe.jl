using TimeFrames
using TimeFrames: shortcut

using Base.Test

tf = YearEnd()
@test tf.period.value == 1

@test YearEnd() == YearEnd()
@test YearEnd() != YearEnd(5)

tf = Minute()
@test tf.period.value == 1

tf = Minute(15)
@test tf.period.value == 15

tf1 = Minute(15)
tf2 = Minute(15)
@test tf1 == tf2

tf1 = Minute(15)
tf2 = Minute(30)
@test tf1 != tf2

tf = Minute()
@test shortcut(tf) == "T"

tf = Minute(15)
@test shortcut(tf) == "15T"

tf = TimeFrame("15T")
@test tf.period.value == 15
@test typeof(tf) == Minute

tf = TimeFrame("T")
@test tf.period.value == 1
@test typeof(tf) == Minute

tf = TimeFrame("15Min")
@test tf.period.value == 15
@test shortcut(tf) == "15T"
@test typeof(tf) == Minute

tf = TimeFrame("5H")
@test tf.period.value == 5
@test typeof(tf) == Hour

# Boundary
@test YearEnd() != YearBegin()
@test apply(MonthEnd(), Date(2010, 2, 20)) == Date(2010, 2, 28)
@test apply(MonthEnd(), DateTime(2010, 2, 20)) == DateTime(2010, 2, 28, 23, 59, 59, 999)

tf = TimeFrame("3A")
@test tf == YearEnd(3)
@test tf.period == Dates.Year(3)
@test tf.boundary == End

tf = TimeFrame("3AS")
@test tf == YearBegin(3)
@test tf.period == Dates.Year(3)
#@test tf.boundary == Begin  # ToFix

tf = TimeFrame("3M")
@test tf == MonthEnd(3)
@test tf.period == Dates.Month(3)
@test tf.boundary == End

tf = TimeFrame("3MS")
@test tf == MonthBegin(3)
@test tf.period == Dates.Month(3)
#@test tf.boundary == Begin  # ToFix

# Grouper
d = Date(2016, 7, 20)
dt = DateTime(2016, 7, 20, 13, 24, 35, 245)

tf = TimeFrame(dt -> floor(dt, Dates.Minute(15)))  # custom TimeFrame with lambda function as DateTime grouper
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 15, 0, 0)

tf = TimeFrame(Dates.Minute(15))  # TimePeriodFrame using TimePeriod
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 15, 0, 0)

tf = TimeFrame(Dates.Day(1))  # TimePeriodFrame using DatePeriod
@test apply(tf, dt) == DateTime(2016, 7, 20, 0, 0, 0, 0)

tf = YearBegin()
#@test apply(tf, dt) == DateTime(2016, 1, 1, 0, 0, 0, 0)
@test apply(tf, dt) == Date(2016, 1, 1)
#@test typeof(f_group(dt)) == Date

#tf = YearEnd(boundary=End)
#@test apply(tf, dt) == DateTime(2016, 1, 1, 0, 0, 0, 0)
#@test apply(tf, dt) == Date(2016, 1, 1)


tf = MonthBegin()
#@test apply(tf, dt) == DateTime(2016, 7, 1, 0, 0, 0, 0)
@test apply(tf, dt) == Date(2016, 7, 1)

tf = Week()
#@test apply(tf, dt) == DateTime(2016, 7, 18, 0, 0, 0, 0)
@test apply(tf, dt) == Date(2016, 7, 18)

tf = Day()
#@test apply(tf, dt) == DateTime(2016, 7, 20, 0, 0, 0, 0)
@test apply(tf, dt) == Date(2016, 7, 20)

tf = Hour()
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 0, 0, 0)

tf = Minute()
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 24, 0, 0)

tf = Second()
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 24, 35, 0)

tf = Millisecond()
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 24, 35, 245)

tf = YearBegin(10)
@test apply(tf, dt) == DateTime(2010, 1, 1, 0, 0, 0, 0)

tf = YearEnd(10)
@test apply(tf, d) == DateTime(2019, 12, 31)
@test apply(tf, dt) == DateTime(2019, 12, 31, 23, 59, 59, 999)

tf = Minute(15)
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 15, 0, 0)

# No timeframe
tf = TimeFrame("")
@test typeof(tf) == NoTimeFrame
@test NoTimeFrame() == NoTimeFrame(1,2,3)

tf = TimeFrame()
@test typeof(tf) == NoTimeFrame

# range
dt1 = DateTime(2010, 1, 1, 20)
dt2 = DateTime(2010, 1, 14, 16)
for tf in [Dates.Day(1), Day(1)]  # Should works both with Period and TimeFrame
    rng = range(dt1, tf, dt2)
    @test rng[1] == DateTime(2010, 1, 1)
    @test rng[end] == DateTime(2010, 1, 14)

    rng = range(dt1, tf, dt2, apply_tf=false)
    @test rng[1] == DateTime(2010, 1, 1, 20)
    @test rng[end] == DateTime(2010, 1, 13, 20)
end


for tf in [Dates.Day(1), Day(1)]  # Should works both with Period and TimeFrame
    N = 5
    rng = range(dt1, tf, N)
    @test length(rng) == N
    @test rng[1] == DateTime(2010, 1, 1, 20)
    @test rng[end] == DateTime(2010, 1, 5, 20)
end


for tf in [Dates.Day(1), Day(1)]  # Should works both with Period and TimeFrame
    N = 5
    rng = range(tf, dt2, N)
    @test length(rng) == N
    @test rng[end] == DateTime(2010, 1, 13, 16)
    @test rng[1] == DateTime(2010, 1, 9, 16)
end

dt1 = DateTime(2010, 1, 1, 20)
dt2 = DateTime(2010, 1, 14, 16)
tf = NoTimeFrame()
@test range(dt1, tf, dt2) == dt1
