using JpegTurbo
using Documenter
using ImageCore, TestImages

DocMeta.setdocmeta!(JpegTurbo, :DocTestSetup, :(using JpegTurbo); recursive=true)

# ensure TestImages artifacts are downloaded before running documenter test
img = testimage("cameraman");

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
    doctest=true, # doctest are run in unit test
)

deploydocs(;
    repo="github.com/JuliaIO/JpegTurbo.jl",
    devbranch="master",
)
