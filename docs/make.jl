using JpegTurbo
using Documenter

format = Documenter.HTML(
    prettyurls = get(ENV, "CI", nothing) == "true"
)

makedocs(;
    modules=[JpegTurbo],
    sitename="JpegTurbo.jl",
    format=format,
    pages=[
        "Home" => "index.md",
        "Reference" => "reference.md",
    ],
)

deploydocs(;
    repo="github.com/johnnychen94/JpegTurbo.jl",
    devbranch="master",
)
