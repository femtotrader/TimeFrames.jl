using TestItemRunner

@testitem "Submillisecond precision" begin
    using Dates
    using NanoDates
    using TimeFrames

    @test !isnothing(Base.get_extension(TimeFrames, :TimeFramesNanoDatesExt))

    @test TimeFrame("U").period == Dates.Microsecond(1)
    @test TimeFrame("10us").period == Dates.Microsecond(10)
    @test TimeFrame("N").period == Dates.Nanosecond(1)
    @test String(tf"10ns") == "10N"
    @test String(tf"10us") == "10U"
    @testset "Time buckets" begin
        time = Dates.Time(12, 0, 0, 0, 123, 456)
        @test apply(tf"10U", time) == Dates.Time(12, 0, 0, 0, 120)
        @test apply(TimeFrame("10U"; boundary = End), time) ==
              Dates.Time(12, 0, 0, 0, 129, 999)
        @test apply(tf"10N", time) == Dates.Time(12, 0, 0, 0, 123, 450)
        @test apply(TimeFrame("10N"; boundary = End), time) ==
              Dates.Time(12, 0, 0, 0, 123, 459)
        @test apply(tf"10U", Dates.Time(0, 0, 0, 0, 1)) == Dates.Time(0)
        @test apply(TimeFrame("10U"; boundary = End), Dates.Time(0)) ==
              Dates.Time(23, 59, 59, 999, 999, 999)
        @test time + tf"N" == time + Dates.Nanosecond(1)
    end
    @testset "NanoDate buckets" begin
        dt = NanoDate(2024, 1, 1, 12, 0, 0, 0, 123, 456)
        @test apply(tf"10U", dt) == NanoDate(2024, 1, 1, 12, 0, 0, 0, 120)
        @test apply(TimeFrame("10U"; boundary = End), dt) ==
              NanoDate(2024, 1, 1, 12, 0, 0, 0, 129, 999)
        @test apply(tf"10N", dt) == NanoDate(2024, 1, 1, 12, 0, 0, 0, 123, 450)
        @test dt + tf"N" == dt + Dates.Nanosecond(1)
        @test TimeFrames.tonext(tf"10U", dt) ==
              NanoDate(2024, 1, 1, 12, 0, 0, 0, 130)
        @test apply(tf"10U", NanoDate(1960, 1, 1, 0, 0, 0, 0, 123, 456)) ==
              NanoDate(1960, 1, 1, 0, 0, 0, 0, 120)
    end
    @testset "DateTime precision limits" begin
        @test_throws InexactError apply(tf"U", DateTime(2024, 1, 1))
        @test_throws InexactError DateTime(2024, 1, 1) + tf"N"
        @test_throws InexactError DateTime(2024, 1, 1) - tf"N"
        @test_throws InexactError DateTime(2024, 1, 1):tf"N":DateTime(
            2024,
            1,
            2,
        )
        @test_throws InexactError range(DateTime(2024, 1, 1), tf"N"; length = 2)
        @test_throws InexactError date_range(
            DateTime(2024, 1, 1),
            tf"N",
            DateTime(2024, 1, 2),
        )
        @test DateTime(2024, 1, 1) + tf"1000U" ==
              DateTime(2024, 1, 1, 0, 0, 0, 1)
        @test apply(tf"1000U", DateTime(2024, 1, 1, 0, 0, 0, 1)) ==
              DateTime(2024, 1, 1, 0, 0, 0, 1)
    end
end

@testitem "NanoDates extension load order" begin
    project = dirname(Base.active_project())
    for imports in (
        "using TimeFrames; @assert isnothing(Base.get_extension(TimeFrames, :TimeFramesNanoDatesExt)); using NanoDates",
        "using NanoDates; using TimeFrames",
    )
        script =
            imports *
            "; using Dates; " *
            "@assert !isnothing(Base.get_extension(TimeFrames, :TimeFramesNanoDatesExt)); " *
            "dt = NanoDates.NanoDate(2024, 1, 1, 0, 0, 0, 0, 123, 456); " *
            "@assert TimeFrames.apply(TimeFrames.TimeFrame(\"10U\"), dt) == " *
            "NanoDates.NanoDate(2024, 1, 1, 0, 0, 0, 0, 120)"
        @test success(
            `$(Base.julia_cmd()) --startup-file=no --project=$project -e $script`,
        )
    end
end
