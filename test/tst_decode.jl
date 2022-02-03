@testset "jpeg_decode" begin
    img_rgb = testimage("lighthouse")
    img_rgb_bytes = jpeg_encode(img_rgb)

    # ensure default keyword values are not changed by accident
    @test jpeg_decode(img_rgb_bytes) ≈
        jpeg_decode(RGB, img_rgb_bytes; transpose=false, scale_ratio=1) ≈
        jpeg_decode(img_rgb_bytes; transpose=false, scale_ratio=1)

    @testset "filename and IOStream" begin
        tmpfile = joinpath(tmpdir, "tmp.jpg")
        jpeg_encode(tmpfile, img_rgb)
        @test read(tmpfile) == img_rgb_bytes

        # IOStream
        img = open(tmpfile, "r") do io
            jpeg_decode(io)
        end
        @test img == jpeg_decode(img_rgb_bytes)

        img = open(tmpfile, "r") do io
            jpeg_decode(Gray, io; scale_ratio=0.5)
        end
        @test img == jpeg_decode(Gray, img_rgb_bytes; scale_ratio=0.5)

        # filename
        @test jpeg_decode(tmpfile) == jpeg_decode(img_rgb_bytes)
        @test jpeg_decode(Gray, tmpfile; scale_ratio=0.5) == jpeg_decode(Gray, img_rgb_bytes; scale_ratio=0.5)
    end

    @testset "colorspace" begin
        native_color_spaces = [Gray, RGB, BGR, RGBA, BGRA, ABGR, ARGB]
        ext_color_spaces = [YCbCr, RGBX, XRGB, Lab, YIQ] # supported by Colors.jl
        for CT in [native_color_spaces..., ext_color_spaces...]
            data = jpeg_decode(CT, img_rgb_bytes)
            @test eltype(data) <: CT
            if CT == Gray
                @test assess_psnr(data, Gray.(img_rgb)) > 34.92
            else
                @test assess_psnr(RGB.(data), img_rgb) > 33.87
            end
        end
    end

    @testset "scale_ratio" begin
        data = jpeg_decode(img_rgb_bytes; scale_ratio=0.25)
        @test size(data) == (128, 192) == 0.25 .* size(img_rgb)

        # `jpeg_decode` will map input `scale_ratio` to allowed values.
        data = jpeg_decode(img_rgb_bytes; scale_ratio=0.3)
        @test size(data) == (128, 192) != 0.3 .* size(img_rgb)
    end

    @testset "transpose" begin
        data = jpeg_decode(jpeg_encode(img_rgb; transpose=true); transpose=true)
        @test assess_psnr(data, img_rgb) > 33.95
    end
end
