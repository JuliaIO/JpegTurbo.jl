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
