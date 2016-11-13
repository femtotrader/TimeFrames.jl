using TimeFrames: TimeFrame
using TimeFrames: Yearly, Monthly, Weekly, Daily, Hourly, Minutely, Secondly, Millisecondly
using TimeFrames: shortcut
using TimeFrames: Begin, End
using TimeFrames: apply

using Base.Test

tf = Yearly()
@test tf.time_period.value == 1

@test Yearly() == Yearly()
@test Yearly() != Yearly(5)

tf = Minutely()
@test tf.time_period.value == 1

tf = Minutely(15)
@test tf.time_period.value == 15

tf1 = Minutely(15)
tf2 = Minutely(15)
@test tf1 == tf2

tf1 = Minutely(15)
tf2 = Minutely(30)
@test tf1 != tf2

tf = Minutely()
@test shortcut(tf) == "T"

tf = Minutely(15)
@test shortcut(tf) == "15T"

tf = TimeFrame("15T")
@test tf.time_period.value == 15
@test typeof(tf) == Minutely

tf = TimeFrame("T")
@test tf.time_period.value == 1
@test typeof(tf) == Minutely

tf = TimeFrame("15Min")
@test tf.time_period.value == 15
@test shortcut(tf) == "15T"
@test typeof(tf) == Minutely

tf = TimeFrame("5H")
@test tf.time_period.value == 5
@test typeof(tf) == Hourly

# Boundary
@test Yearly(boundary=End) != Yearly(boundary=Begin)
@test apply(Monthly(boundary=End), Date(2010, 2, 20)) == Date(2010, 2, 28)
@test apply(Monthly(boundary=End), DateTime(2010, 2, 20)) == DateTime(2010, 2, 28, 23, 59, 59, 999)

# Grouper
d = Date(2016, 7, 20)
dt = DateTime(2016, 7, 20, 13, 24, 35, 245)

tf = TimeFrame(dt -> floor(dt, Dates.Minute(15)))  # custom TimeFrame with lambda function as DateTime grouper
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 15, 0, 0)

tf = TimeFrame(Dates.Minute(15))  # TimePeriodFrame using TimePeriod
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 15, 0, 0)

tf = TimeFrame(Dates.Day(1))  # TimePeriodFrame using DatePeriod
@test apply(tf, dt) == DateTime(2016, 7, 20, 0, 0, 0, 0)

tf = Yearly()
#@test apply(tf, dt) == DateTime(2016, 1, 1, 0, 0, 0, 0)
@test apply(tf, dt) == Date(2016, 1, 1)
#@test typeof(f_group(dt)) == Date

tf = Monthly()
#@test apply(tf, dt) == DateTime(2016, 7, 1, 0, 0, 0, 0)
@test apply(tf, dt) == Date(2016, 7, 1)

tf = Weekly()
#@test apply(tf, dt) == DateTime(2016, 7, 18, 0, 0, 0, 0)
@test apply(tf, dt) == Date(2016, 7, 18)

tf = Daily()
#@test apply(tf, dt) == DateTime(2016, 7, 20, 0, 0, 0, 0)
@test apply(tf, dt) == Date(2016, 7, 20)

tf = Hourly()
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 0, 0, 0)

tf = Minutely()
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 24, 0, 0)

tf = Secondly()
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 24, 35, 0)

tf = Millisecondly()
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 24, 35, 245)

tf = Yearly(10)
@test apply(tf, dt) == DateTime(2010, 1, 1, 0, 0, 0, 0)

tf = Yearly(10, boundary=End)
@test apply(tf, d) == DateTime(2019, 12, 31)
@test apply(tf, dt) == DateTime(2019, 12, 31, 23, 59, 59, 999)

tf = Minutely(15)
@test apply(tf, dt) == DateTime(2016, 7, 20, 13, 15, 0, 0)
