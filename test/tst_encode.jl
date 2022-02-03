@testset "jpeg_encode" begin

img_rgb = testimage("lighthouse")

@testset "basic" begin
    for CT in [Gray, RGB, #=YCbCr,=# #=RGBX,=# BGR, #=XRGB,=# RGBA, BGRA, ABGR, ARGB]
        img = CT.(img_rgb)
        data = decode_encode(img)
        @test eltype(data) <: Union{Gray, RGB}
        @test size(data) == size(img)
        @test data ≈ decode_encode(float32.(img))

        # ensure default keyword values are not changed by accident
        @test data == decode_encode(img, transpose=false)
        @test decode_encode(img, transpose=true) == decode_encode(img', transpose=false)
    end

    # numerical array is treated as Gray image
    img = Gray.(img_rgb)
    @test jpeg_encode(Float32.(img)) == jpeg_encode(img)

    # out-of-range values are mapped into [0, 1]
    img_or = 1.5 .* img
    img_or[1] = Gray(NaN)
    @test jpeg_encode(img_or) == jpeg_encode(Float64.(img_or)) == jpeg_encode(clamp01nan!(img_or))
end

# keyword checks
@testset "quality" begin
    img = testimage("cameraman")
    psnr_refs = [
        1   => 24.63,
        10  => 31.34,
        50  => 38.87,
        100 => 59.31,
    ]
    for (q, r) in psnr_refs
        v = assess_psnr(img, decode_encode(img, quality=q))
        @test v >= r
    end
end

end # @testset "jpeg_encode"
