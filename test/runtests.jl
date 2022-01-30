using JpegTurbo
using JpegTurbo.LibJpeg
using Test

@testset "JpegTurbo.jl" begin
    @testset "config" begin
        @test_nowarn JpegTurbo.versioninfo()

        # ensure we're using SIMD-built version for performance
        @test LibJpeg.WITH_SIMD == 1

        # use the 8-bit version
        @test LibJpeg.JSAMPLE == UInt8
        @test LibJpeg.BITS_IN_JSAMPLE == 8
        @test LibJpeg.MAXJSAMPLE == 255
        @test LibJpeg.CENTERJSAMPLE == 128
    end
end
