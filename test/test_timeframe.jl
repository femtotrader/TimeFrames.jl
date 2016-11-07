using TimeFrames: TimeFrame
using TimeFrames: Yearly, Monthly, Weekly, Daily, Hourly, Minutely, Secondly, Millisecondly
using TimeFrames: shortcut, dt_grouper
using TimeFrames: Begin, End

using Base.Test

tf = Yearly()
@test tf.time_period.value == 1

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

# Grouper
dt = DateTime(2016, 7, 20, 13, 24, 35, 245)

tf = TimeFrame(dt -> floor(dt, Dates.Minute(15)))  # custom TimeFrame with lambda function as DateTime grouper
f_group = dt_grouper(tf)
@test f_group(dt) == DateTime(2016, 7, 20, 13, 15, 0, 0)

f_group = dt_grouper(Yearly())
#@test f_group(dt) == 2016
#@test f_group(dt) == DateTime(2016, 1, 1, 0, 0, 0, 0)
@test f_group(dt) == Date(2016, 1, 1)
#@test typeof(f_group(dt)) == Date

f_group = dt_grouper(Monthly())
#@test f_group(dt) == (2016, 7)
#@test f_group(dt) == DateTime(2016, 7, 1, 0, 0, 0, 0)
@test f_group(dt) == Date(2016, 7, 1)

f_group = dt_grouper(Weekly())
#@test f_group(dt) == DateTime(2016, 7, 18, 0, 0, 0, 0)
@test f_group(dt) == Date(2016, 7, 18)

f_group = dt_grouper(Daily())
#@test f_group(dt) == (2016, 7, 20)
#@test f_group(dt) == DateTime(2016, 7, 20, 0, 0, 0, 0)
@test f_group(dt) == Date(2016, 7, 20)

f_group = dt_grouper(Hourly())
#@test f_group(dt) == (2016, 7, 20, 13)
@test f_group(dt) == DateTime(2016, 7, 20, 13, 0, 0, 0)

f_group = dt_grouper(Minutely())
#@test f_group(dt) == (2016, 7, 20, 13, 24)
@test f_group(dt) == DateTime(2016, 7, 20, 13, 24, 0, 0)

f_group = dt_grouper(Secondly())
#@test f_group(dt) == (2016, 7, 20, 13, 24, 35)
@test f_group(dt) == DateTime(2016, 7, 20, 13, 24, 35, 0)

f_group = dt_grouper(Millisecondly())
#@test f_group(dt) == (2016, 7, 20, 13, 24, 35, 245)
@test f_group(dt) == DateTime(2016, 7, 20, 13, 24, 35, 245)

f_group = dt_grouper(Yearly(10))
@test f_group(dt) == DateTime(2010, 1, 1, 0, 0, 0, 0)

f_group = dt_grouper(Yearly(10, boundary=End))
@test f_group(dt) == DateTime(2020, 1, 1, 0, 0, 0, 0)

f_group = dt_grouper(Minutely(15))
@test f_group(dt) == DateTime(2016, 7, 20, 13, 15, 0, 0)
