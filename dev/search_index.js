var documenterSearchIndex = {"docs":
[{"location":"reference/","page":"Reference","title":"Reference","text":"CurrentModule = JpegTurbo","category":"page"},{"location":"reference/#Function-references","page":"Reference","title":"Function references","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"jpeg_encode\njpeg_decode","category":"page"},{"location":"reference/#JpegTurbo.jpeg_encode","page":"Reference","title":"JpegTurbo.jpeg_encode","text":"jpeg_encode(filename::AbstractString, img; kwargs...) -> Int\njpeg_encode(io::IO, img; kwargs...) -> Int\njpeg_encode(img; kwargs...) -> Vector{UInt8}\n\nEncode 2D image img as JPEG byte sequences and write to given I/O stream or file. The return value is number of bytes. If output is not specified, the encoded result is stored in memory as return value.\n\nParameters\n\ntranspose::Bool: whether we need to permute the image's width and height dimension before encoding. The default value is false.\nquality::Int: Constructs JPEG quantization tables appropriate for the indicated quality setting. The quality value is expressed on the 0..100 scale recommended by IJG. The default value is 92. Pass quality=nothing to let libjpeg-turbo dynamicly guess a value.\n\ninfo: Custom compression parameters\nJPEG has a large number of compression parameters that determine how the image is encoded. Most applications don't need or want to know about all these parameters. For more detailed information and explaination, please refer to the \"Compression parameter selection\" in [1]. Unsupported custom parameters might cause Julia segmentation fault.\n\nExamples\n\njulia> using JpegTurbo, TestImages\n\njulia> img = testimage(\"cameraman\");\n\njulia> jpeg_encode(\"out.jpg\", img) # write to file\n51396\n\njulia> buf = jpeg_encode(img); length(buf) # directly write to memory\n51396\n\nReferences\n\n[1] libjpeg API Documentation (libjpeg.txt)\n\n\n\n\n\n","category":"function"},{"location":"reference/#JpegTurbo.jpeg_decode","page":"Reference","title":"JpegTurbo.jpeg_decode","text":"jpeg_decode([T,] filename::AbstractString; kwargs...) -> Matrix{T}\n\nDecode the JPEG image from given I/O stream as colorant matrix.\n\nparameters\n\ntranspose::Bool: whether we need to permute the image's width and height dimension before encoding. The default value is false.\nscale_ratio::Real: scale the image by ratio scale_ratio in M/8 with M ∈ 1:16. The default value is 1. For values are not in the range, they will be mapped to the nearest value, e.g., 0.3 => 2/8 and 0.35 => 3/8.\n\nExamples\n\njulia> using JpegTurbo, TestImages, ImageCore\n\njulia> filename = testimage(\"earth\", download_only=true);\n\njulia> img = jpeg_decode(filename); summary(img)\n\"3002×3000 Array{RGB{N0f8},2} with eltype RGB{N0f8}\"\n\njulia> img = jpeg_decode(Gray, filename; scale_ratio=0.25); summary(img)\n\"751×750 Array{Gray{N0f8},2} with eltype Gray{N0f8}\"\n\nFor image preview and similar purposes, T and scale_ratio are useful parameters to accelerate the JPEG decoding process. For color JPEG image, jpeg_decode(Gray, filename) is faster than jpeg_decode(filename) since the color components need not be processed. Smaller scale_ratio permits significantly faster decoding since fewer pixels need be processed and a simpler IDCT method can be used.\n\nusing BenchmarkTools, TestImages, JpegTurbo\nfilename = testimage(\"earth\", download_only=true)\n# full decompression\n@btime jpeg_decode(filename); # 224.760 ms (7 allocations: 51.54 MiB)\n# only decompress luminance component\n@btime jpeg_decode(Gray, filename); # 91.157 ms (6 allocations: 17.18 MiB)\n# process only a few pixels\n@btime jpeg_decode(filename; scale_ratio=0.25); # 77.254 ms (8 allocations: 3.23 MiB)\n# process only a few pixels for luminance component\n@btime jpeg_decode(Gray, filename; scale_ratio=0.25); # 63.119 ms (6 allocations: 1.08 MiB)\n\n\n\n\n\n","category":"function"},{"location":"reference/#Utilities","page":"Reference","title":"Utilities","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"versioninfo","category":"page"},{"location":"reference/#JpegTurbo.versioninfo","page":"Reference","title":"JpegTurbo.versioninfo","text":"versioninfo()\n\nPrint information about the libjpeg-turbo in use.\n\n\n\n\n\n","category":"function"},{"location":"#JpegTurbo","page":"Home","title":"JpegTurbo","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"JpegTurbo.jl is a Julia wrapper of the C library libjpeg-turbo that provides IO support for the JPEG image format.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The main functionality of this package consist of two functions: jpeg_encode and jpeg_decode. Check the function references for more details.","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"jpeg_encode is used to compress 2D colorant matrix as JPEG image.","category":"page"},{"location":"","page":"Home","title":"Home","text":"jpeg_encode(filename::AbstractString, img; kwargs...) -> Int\njpeg_encode(io::IO, img; kwargs...) -> Int\njpeg_encode(img; kwargs...) -> Vector{UInt8}","category":"page"},{"location":"","page":"Home","title":"Home","text":"jpeg_decode is used to decompress JPEG image as 2D colorant matrix.","category":"page"},{"location":"","page":"Home","title":"Home","text":"jpeg_decode([T,] filename::AbstractString; kwargs...) -> Matrix{T}","category":"page"},{"location":"#Feature-set","page":"Home","title":"Feature set","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"function filename IOStream in-memory buffer pre-allocated output multi-threads\njpeg_encode x x x  x\njpeg_decode x    x\nImageMagick.save x x x  x\nImageMagick.load x x x  x\nQuartzImageIO.save x x x (FileIO.Stream)  x\nQuartzImageIO.load x x x (FileIO.Stream)  x","category":"page"},{"location":"","page":"Home","title":"Home","text":"Notes:","category":"page"},{"location":"","page":"Home","title":"Home","text":"x: supported\nempty: missing/unsupported yet","category":"page"}]
}
