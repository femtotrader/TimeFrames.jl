using TestItemRunner

@testitem "Calendar boundaries and date ranges" begin
    using Dates
    using TimeFrames

    @testset "Next boundary" begin
        @test TimeFrames.tonext(tf"M", Date(2010, 1, 1)) == Date(2010, 1, 31)
        @test TimeFrames.tonext(tf"M", Date(2024, 2, 29)) == Date(2024, 3, 31)
        @test TimeFrames.tonext(tf"M", Date(2024, 2, 29); same = true) ==
              Date(2024, 2, 29)
        @test TimeFrames.tonext(
            tf"M",
            DateTime(2024, 2, 29, 23, 59, 59, 999),
        ) == DateTime(2024, 3, 31, 23, 59, 59, 999)
        @test Date(2010, 1, 1) + tf"M" == Date(2010, 2, 1)
    end

    @testset "Week anchors" begin
        sunday = TimeFrame("W"; firstdayofweek = 7)
        @test apply(sunday, Date(2024, 1, 3)) == Date(2023, 12, 31)
        @test apply(sunday, Date(2024, 1, 7)) == Date(2024, 1, 7)
        @test (2 * sunday).firstdayofweek == 7
        @test TimeFrame("W"; firstdayofweek = 7, boundary = End).firstdayofweek ==
              7
        @test apply(
            TimeFrame("W"; firstdayofweek = 7, boundary = End),
            Date(2024, 1, 3),
        ) == Date(2024, 1, 6)
        @test_throws ArgumentError TimeFrame("W"; firstdayofweek = 0)
        @test_throws ArgumentError TimeFrame("D"; firstdayofweek = 7)
    end

    @testset "Business months" begin
        @test apply(tf"BM", Date(2024, 3, 15)) == Date(2024, 3, 29)
        @test apply(tf"BMS", Date(2024, 6, 15)) == Date(2024, 6, 3)
        @test String(tf"2BM") == "2BM"
        @test TimeFrames.tonext(tf"BM", Date(2024, 3, 30)) == Date(2024, 4, 30)
    end

    @testset "Inclusive calendar ranges" begin
        @test date_range(Date(2010, 1, 1), tf"MS", Date(2020, 1, 1)) ==
              collect(Date(2010, 1, 1):Dates.Month(1):Date(2020, 1, 1))
        ends = date_range(Date(2010, 1, 1), tf"M", Date(2020, 1, 1))
        @test length(ends) == 120
        @test first(ends) == Date(2010, 1, 31)
        @test last(ends) == Date(2019, 12, 31)
        @test date_range(Date(2024, 1, 1), tf"M", Date(2024, 3, 31)) ==
              [Date(2024, 1, 31), Date(2024, 2, 29), Date(2024, 3, 31)]
        @test date_range(Date(2024, 3, 1), tf"BM", Date(2024, 6, 30)) == [
            Date(2024, 3, 29),
            Date(2024, 4, 30),
            Date(2024, 5, 31),
            Date(2024, 6, 28),
        ]
        start = DateTime(2010, 1, 1, 20)
        @test date_range(start, tf"D", DateTime(2010, 1, 4)) ==
              [start, start + Dates.Day(1), start + Dates.Day(2)]
        @test isempty(date_range(Date(2024, 2, 1), tf"D", Date(2024, 1, 1)))
        @test collect(
            range(Date(2024, 1, 1), tf"D"; stop = Date(2024, 1, 3)),
        ) == [Date(2024, 1, 1), Date(2024, 1, 2), Date(2024, 1, 3)]
        @test length(range(Date(2024, 1, 1), tf"D"; length = 3)) == 3
        @test_throws ArgumentError range(Date(2024, 1, 1), tf"D")
        @test_throws ArgumentError range(
            Date(2024, 1, 1),
            tf"D";
            stop = Date(2024, 1, 3),
            length = 3,
        )
        @test_throws ArgumentError date_range(
            Date(2024, 1, 1),
            -1 * tf"D",
            Date(2024, 1, 3),
        )
    end
end
