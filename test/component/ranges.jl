using TestItemRunner

@testitem "Colon ranges" begin
    using Dates
    using TimeFrames

    start = DateTime(2024, 1, 1, 12, 2)
    stop = start + Dates.Minute(11)
    @test collect(start:tf"5T":stop) ==
          [start, start + Dates.Minute(5), start + Dates.Minute(10)]
    @test collect(start:tf"5T":(start+Dates.Minute(10))) ==
          collect(start:Dates.Minute(5):(start+Dates.Minute(10)))
    @test collect(stop:(-1*tf"5T"):start) ==
          collect(stop:Dates.Minute(-5):start)
    @test isempty(stop:tf"5T":start)
    @test collect(Date(2024, 1, 31):tf"M":Date(2024, 3, 31)) ==
          [Date(2024, 1, 31), Date(2024, 2, 29), Date(2024, 3, 31)]
end
