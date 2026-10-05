using Documenter
using DocumenterLandingPage
using TimeFrames

DocMeta.setdocmeta!(
    TimeFrames,
    :DocTestSetup,
    :(using Dates, TimeFrames);
    recursive = true,
)

pages = [
    "Home" => "index.md",
    "Usage" => "usage.md",
    "Migration" => "migration.md",
    "API" => "api.md",
    "Requirements" => "requirements.md",
]

# Build outside the repository by default; CI and maintainers can choose a path.
build_dir =
    get(ENV, "TIMEFRAMES_DOCS_BUILD", joinpath(tempdir(), "timeframes-docs"))
makedocs(
    modules = [TimeFrames],
    sitename = "TimeFrames.jl",
    authors = "FemtoTrader",
    source = "src",
    build = build_dir,
    pages = pages,
    plugins = [LandingPage()],
    doctest = true,
    checkdocs = :exports,
    warnonly = false,
    format = Documenter.HTML(prettyurls = true, edit_link = "main"),
)

base_url = "https://femtotrader.github.io/TimeFrames.jl"
open(joinpath(build_dir, "llms.txt"), "w") do io
    println(io, "# TimeFrames.jl")
    println(
        io,
        "\n> Julia time buckets for resampling, supporting Julia 1.10 and later.",
    )
    println(io, "\n## Documentation\n")
    for (title, filename) in pages
        page_path =
            filename == "index.md" ? "" : replace(filename, ".md" => "/")
        println(io, "- [$title]($base_url/$page_path)")
    end
end

open(joinpath(build_dir, "llms-full.txt"), "w") do io
    println(io, "# TimeFrames.jl documentation\n")
    for (_, filename) in pages
        println(io, read(joinpath(@__DIR__, "src", filename), String))
        println(io)
    end
    println(io, "# API docstrings\n")
    for name in (
        :TimeFrame,
        :Boundary,
        :Begin,
        :End,
        :NoTimeFrame,
        :YearBegin,
        :YearEnd,
        :MonthBegin,
        :MonthEnd,
        :apply,
        Symbol("@tf_str"),
    )
        println(io, "## ", name, "\n")
        println(io, Base.Docs.doc(Base.Docs.Binding(TimeFrames, name)))
        println(io)
    end
    println(io, "## range\n")
    println(
        io,
        @doc TimeFrames.range(
            ::TimeFrames.Dates.TimeType,
            ::TimeFrames.AbstractPeriodFrame,
            ::TimeFrames.Dates.TimeType,
        )
    )
end

@assert isfile(joinpath(build_dir, "index.html"))
@assert occursin(
    "landing-hero",
    read(joinpath(build_dir, "index.html"), String),
)
@assert filesize(joinpath(build_dir, "llms.txt")) > 0
@assert filesize(joinpath(build_dir, "llms-full.txt")) > 0
