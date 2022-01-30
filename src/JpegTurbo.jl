module JpegTurbo

using ImageCore

include("../lib/LibJpeg.jl")
using .LibJpeg
include("libjpeg_utils.jl")

include("common.jl")
include("encode.jl")

export jpeg_encode

end
