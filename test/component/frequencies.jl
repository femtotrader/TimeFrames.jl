using TestItemRunner

@testitem "Frequency aliases" begin
    using Dates
    using TimeFrames

    @test TimeFrame("250ms").period == Dates.Millisecond(250)
    @test TimeFrame("ms").period == Dates.Millisecond(1)
    @test TimeFrame("250MS").period == Dates.Month(250)
    @test TimeFrame("MS").boundary == Begin
    @test String(tf"250ms") == "250L"
    @test TimeFrame(SubString("x5ms", 2)).period == Dates.Millisecond(5)
    @test TimeFrame("5ms"; boundary = End).boundary == End
    @test_throws ArgumentError TimeFrame("0ms")
    @test_throws ArgumentError TimeFrame("-1ms")
    for unit in ("A", "AS", "M", "MS", "W", "D", "H", "T", "S", "L")
        @test TimeFrame(unit).period == TimeFrame("1" * unit).period
    end
end
