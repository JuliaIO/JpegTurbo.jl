@testset "jpeg_decode" begin
    img_rgb = testimage("lighthouse")

    tmpfile = joinpath(tmpdir, "tmp.jpg")
    jpeg_encode(tmpfile, img_rgb)

    data = jpeg_decode(tmpfile)

    @test jpeg_decode(tmpfile; transpose=true) == data'

    # ensure default keyword values are not changed by accident
    @test jpeg_decode(tmpfile) ≈
        jpeg_decode(RGB, tmpfile; transpose=false, scale_ratio=1) ≈
        jpeg_decode(tmpfile; transpose=false, scale_ratio=1)


    # TODO(johnnychen94): support IO and in-memory buffer
    @test_broken jpeg_decode(jpeg_encode(img_rgb))
    @test_broken open(jpeg_decode, tmpfile, "r")

    @testset "colorspace" begin
        native_color_spaces = [Gray, RGB, BGR, RGBA, BGRA, ABGR, ARGB]
        ext_color_spaces = [YCbCr, RGBX, XRGB, Lab, YIQ] # supported by Colors.jl
        for CT in [native_color_spaces..., ext_color_spaces...]
            data = jpeg_decode(CT, tmpfile)
            @test eltype(data) <: CT
            if CT == Gray
                @test assess_psnr(data, Gray.(img_rgb)) > 34.92
            else
                @test assess_psnr(RGB.(data), img_rgb) > 33.87
            end
        end
    end

    @testset "scale_ratio" begin
        data = jpeg_decode(tmpfile; scale_ratio=0.25)
        @test size(data) == (128, 192) == 0.25 .* size(img_rgb)

        # `jpeg_decode` will map input `scale_ratio` to allowed values.
        data = jpeg_decode(tmpfile; scale_ratio=0.3)
        @test size(data) == (128, 192) != 0.3 .* size(img_rgb)
    end

    @testset "transpose" begin
        jpeg_encode(tmpfile, img_rgb; transpose=true)
        data = jpeg_decode(tmpfile; transpose=true)
        @test assess_psnr(data, img_rgb) > 33.95
    end
end
