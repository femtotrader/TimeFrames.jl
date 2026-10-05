using TestItemRunner

@testitem "Modernization regressions" begin
    using Dates
    using TimeFrames
    @testset "Modernization regressions" begin
        @testset "Scoped boundary policy" begin
            @test Boundary === TimeFrames.BoundaryPolicy.T
            @test Begin === TimeFrames.BoundaryPolicy.BEGIN
            @test End === TimeFrames.BoundaryPolicy.END
            @test TimeFrames.UndefBoundary ===
                  TimeFrames.BoundaryPolicy.UNDEFINED
            @test Int(Begin) == 1
            @test Int(End) == 2
        end
        @testset "Explicit boundaries" begin
            tf = TimeFrame("5T"; boundary = End)
            @test tf.boundary == End
            @test tf.period == Dates.Minute(5)
            @test apply(tf, DateTime(2024, 1, 1, 0, 2)) ==
                  DateTime(2024, 1, 1, 0, 5) - Dates.Millisecond(1)
            @test TimeFrame("M"; boundary = Begin).boundary == Begin
            @test TimeFrame(SubString("x15Min", 2)).period == Dates.Minute(15)
        end

        @testset "Invalid frequency input" begin
            for input in (
                "HM",
                "|",
                "12",
                "0T",
                "-1T",
                "1.5H",
                "1XYZ",
                " T",
                "T\n",
                "T ",
                "999999999999999999999999T",
            )
                @test_throws ArgumentError TimeFrame(input)
            end
            @test_throws ArgumentError TimeFrame("T"; boundary = 42)
        end

        @testset "Identity frame" begin
            @test String(NoTimeFrame()) == ""
            for dt in (Date(2024, 1, 1), DateTime(2024, 1, 1), Dates.Time(12))
                @test apply(NoTimeFrame(), dt) === dt
            end
        end

        @testset "Generic period arithmetic" begin
            d = Date(2024, 1, 1)
            for period in (
                Dates.Hour(1),
                Dates.Minute(1),
                Dates.Second(1),
                Dates.Millisecond(1),
            )
                tf = TimeFrame(period)
                @test d + tf == DateTime(d) + period
                @test tf + d == DateTime(d) + period
                @test d - tf == DateTime(d) - period
            end
            @test_throws InexactError Dates.Time(12) + TimeFrame(Dates.Day(1))
        end
    end

end
