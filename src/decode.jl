"""
    jpeg_decode([T,] filename::AbstractString; kwargs...) -> Matrix{T}

Decode the JPEG image from given I/O stream as colorant matrix.

# parameters

- `transpose::Bool`: whether we need to permute the image's width and height dimension
  before encoding. The default value is `false`.
- `scale_ratio::Real`: scale the image by ratio `scale_ratio` in `M/8` with `M ∈ 1:16`. The
  default value is `1`. For values are not in the range, they will be mapped to the nearest
  value, e.g., `0.3 => 2/8` and `0.35 => 3/8`.

# Examples

```jldoctest
julia> using JpegTurbo, TestImages, ImageCore

julia> filename = testimage("earth", download_only=true);

julia> img = jpeg_decode(filename); summary(img)
"3002×3000 Array{RGB{N0f8},2} with eltype RGB{N0f8}"

julia> img = jpeg_decode(Gray, filename; scale_ratio=0.25); summary(img)
"751×750 Array{Gray{N0f8},2} with eltype Gray{N0f8}"
```

For image preview and similar purposes, `T` and `scale_ratio` are useful parameters to
accelerate the JPEG decoding process. For color JPEG image, `jpeg_decode(Gray, filename)` is
faster than `jpeg_decode(filename)` since the color components need not be processed.
Smaller `scale_ratio` permits significantly faster decoding since fewer pixels need be
processed and a simpler IDCT method can be used.

```julia
using BenchmarkTools, TestImages, JpegTurbo
filename = testimage("earth", download_only=true)
# full decompression
@btime jpeg_decode(filename); # 224.760 ms (7 allocations: 51.54 MiB)
# only decompress luminance component
@btime jpeg_decode(Gray, filename); # 91.157 ms (6 allocations: 17.18 MiB)
# process only a few pixels
@btime jpeg_decode(filename; scale_ratio=0.25); # 77.254 ms (8 allocations: 3.23 MiB)
# process only a few pixels for luminance component
@btime jpeg_decode(Gray, filename; scale_ratio=0.25); # 63.119 ms (6 allocations: 1.08 MiB)
```

"""
function jpeg_decode(
        ::Type{CT},
        filename::AbstractString;
        transpose=false,
        scale_ratio=1) where CT<:Colorant
    infile = ccall(:fopen, Libc.FILE, (Cstring, Cstring), filename, "rb")
    @assert infile.ptr != C_NULL
    out_CT, jpeg_cls = _jpeg_out_color_space(CT)

    local cinfo, out
    try
        cinfo = LibJpeg.jpeg_decompress_struct()
        cinfo_ref = Ref(cinfo)
        jerr = Ref{LibJpeg.jpeg_error_mgr}()
        cinfo.err = LibJpeg.jpeg_std_error(jerr)
        LibJpeg.jpeg_create_decompress(cinfo_ref)
        LibJpeg.jpeg_stdio_src(cinfo_ref, infile)
        LibJpeg.jpeg_read_header(cinfo_ref, true)

        # set decompression parameters, if given
        r = _cal_scale_ratio(scale_ratio)
        cinfo.scale_num, cinfo.scale_denom = r.num, r.den
        cinfo.out_color_space = jpeg_cls

        # eagerly calculate dimension information so that `output_XXX` fields are valid.
        LibJpeg.jpeg_calc_output_dimensions(cinfo_ref)
        out_size = (Int(cinfo.output_width), Int(cinfo.output_height))
        if !all(x -> x<=65535, out_size)
            error("Suspicious inferred image size $out_size: each dimension is expected to have at most 65535 pixels.")
        end
        out_ndims = Int(cinfo.output_components)
        @assert out_ndims == length(out_CT) "Suspicous output color space: $cinfo.out_color_space"

        out = Matrix{out_CT}(undef, out_size)
        _jpeg_decode!(out, cinfo)
    finally
        LibJpeg.jpeg_destroy_decompress(Ref(cinfo))
        ccall(:fclose, Cint, (Ptr{Libc.FILE},), infile)
    end

    if out_CT <: CT
        return transpose ? out : permutedims(out, (2, 1))
    else
        return transpose ? CT.(out) : CT.(PermutedDimsArray(out, (2, 1)))
    end
end
function jpeg_decode(filename::AbstractString; kwargs...)
    return jpeg_decode(_default_out_color_space(filename), filename; kwargs...)
end

function _jpeg_decode!(out::Matrix{<:Colorant}, cinfo::LibJpeg.jpeg_decompress_struct)
    cinfo_ref = Ref(cinfo)

    row_stride = size(out, 1) * length(eltype(out))
    buf = Vector{UInt8}(undef, row_stride)
    out_uint8 = reinterpret(UInt8, out)

    LibJpeg.jpeg_start_decompress(cinfo_ref)
    while cinfo.output_scanline < cinfo.output_height
        # TODO(johnnychen94): try if we can directly write to `out` without using `buf`
        GC.@preserve buf LibJpeg.jpeg_read_scanlines(cinfo_ref, Ref(pointer(buf)), 1)
        copyto!(out_uint8, (cinfo.output_scanline-1) * row_stride + 1, buf, 1, row_stride)
    end
    LibJpeg.jpeg_finish_decompress(cinfo_ref)

    return out
end

# libjpeg-turbo only supports ratio M/8 with M from 1 to 16
const _allowed_scale_ratios = ntuple(i->i//8, 16)
_cal_scale_ratio(r::Real) = _allowed_scale_ratios[findmin(x->abs(x-r), _allowed_scale_ratios)[2]]

function _default_out_color_space(filename::AbstractString)
    infile = ccall(:fopen, Libc.FILE, (Cstring, Cstring), filename, "rb")
    @assert infile.ptr != C_NULL
    local cinfo
    try
        cinfo = LibJpeg.jpeg_decompress_struct()
        cinfo_ref = Ref(cinfo)
        jerr = Ref{LibJpeg.jpeg_error_mgr}()
        cinfo.err = LibJpeg.jpeg_std_error(jerr)
        LibJpeg.jpeg_create_decompress(cinfo_ref)
        LibJpeg.jpeg_stdio_src(cinfo_ref, infile)
        LibJpeg.jpeg_read_header(cinfo_ref, true)
        LibJpeg.jpeg_calc_output_dimensions(cinfo_ref)
        return jpeg_color_space(cinfo.out_color_space)
    finally
        LibJpeg.jpeg_destroy_decompress(Ref(cinfo))
        ccall(:fclose, Cint, (Ptr{Libc.FILE},), infile)
    end
end

function _jpeg_out_color_space(::Type{CT}) where CT
    try
        n0f8(CT), jpeg_color_space(n0f8(CT))
    catch e
        @debug "Unsupported libjpeg-turbo color space, fallback to RGB{N0f8}" e
        RGB{N0f8}, jpeg_color_space(RGB{N0f8})
    end
end
