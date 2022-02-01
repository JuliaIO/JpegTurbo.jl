using JpegTurbo
using JpegTurbo.LibJpeg
using Test
using Aqua
using Documenter
using TestImages
using ImageQualityIndexes
using ImageMagick
using ImageCore

tmpdir = tempdir()
function decode_encode(img; kwargs...)
    tmpfile = joinpath(tmpdir, "tmp.jpg")
    buf = @inferred jpeg_encode(img; kwargs...)
    write(tmpfile, buf)
    return jpeg_decode(tmpfile)
end

@testset "JpegTurbo.jl" begin
    @testset "Project meta quality checks" begin
        Aqua.test_all(JpegTurbo;
            ambiguities=false,
            project_extras=true,
            deps_compat=true,
            stale_deps=true,
            project_toml_formatting=true
        )
        doctest(JpegTurbo, manual = false)
    end

    @testset "config" begin
        @test_nowarn JpegTurbo.versioninfo()

        # ensure we're using SIMD-built version for performance
        @test LibJpeg.WITH_SIMD == 1

        # use the 8-bit version
        @test LibJpeg.JSAMPLE == UInt8
        @test LibJpeg.BITS_IN_JSAMPLE == 8
        @test LibJpeg.MAXJSAMPLE == 255
        @test LibJpeg.CENTERJSAMPLE == 128

        # ensure colorspace extensions are supported
        @test LibJpeg.JCS_EXTENSIONS == 1
        @test LibJpeg.JCS_ALPHA_EXTENSIONS == 1
    end

    include("tst_encode.jl")
    include("tst_decode.jl")
    if Threads.nthreads() > 1
        @info "Multi-threads test: enabled"
        include("tst_multithreads.jl")
    else
        @info "Multi-threads test: skipped"
    end
end
