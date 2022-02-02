module JpegTurbo

using ImageCore

include("../lib/LibJpeg.jl")
using .LibJpeg
include("libjpeg_utils.jl")

include("common.jl")
include("encode.jl")
include("decode.jl")

export jpeg_encode, jpeg_decode

end
