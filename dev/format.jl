using JuliaFormatter

mode = isempty(ARGS) ? "check" : only(ARGS)
mode in ("check", "write") || error("Expected check or write")
root = dirname(@__DIR__)
unformatted = String[]
for directory in ("src", "test", "docs", "dev")
    for (path, _, files) in walkdir(joinpath(root, directory))
        for file in files
            endswith(file, ".jl") || continue
            filename = joinpath(path, file)
            formatted = format_file(filename; overwrite = mode == "write")
            formatted || push!(unformatted, relpath(filename, root))
        end
    end
end
if mode == "check" && !isempty(unformatted)
    error("Run just format to format: " * join(unformatted, ", "))
end
