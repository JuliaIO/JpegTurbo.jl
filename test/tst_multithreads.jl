@testset "multithreads" begin
    @test Threads.nthreads() > 1

    img = testimage("lighthouse")
    @testset "jpeg_encode" begin
        ref = jpeg_encode(img)

        out = [fill(zero(UInt8), size(ref)) for _ in 1:Threads.nthreads()]
        Threads.@threads for i in 1:Threads.nthreads()
            out[i] = jpeg_encode(img)
        end
        @test all(out .== Ref(ref))
    end
end
