# JpegTurbo

[JpegTurbo.jl](https://github.com/johnnychen94/JpegTurbo.jl) is a Julia wrapper of the C library
[libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo) that provides IO support for the
JPEG image format.

The main functionality of this package consist of two functions: `jpeg_encode` and `jpeg_decode`.
Check the [function references](@Function-references) for more details.

## API

`jpeg_encode` is used to compress 2D colorant matrix as JPEG image.

```julia
jpeg_encode(filename::AbstractString, img; kwargs...) -> Int
jpeg_encode(io::IO, img; kwargs...) -> Int
jpeg_encode(img; kwargs...) -> Vector{UInt8}
```

`jpeg_decode` is used to decompress JPEG image as 2D colorant matrix.

```julia
jpeg_decode([T,] filename::AbstractString; kwargs...) -> Matrix{T}
jpeg_decode([T,] io::IO; kwargs...) -> Matrix{T}
jpeg_decode([T,] data::Vector{UInt8}; kwargs...) -> Matrix{T}
```

## Feature set

| function             | filename | IOStream | in-memory buffer     | pre-allocated output | multi-threads |
| -------------------- | -------- | -------- | -------------------- | -------------------  | ------------- |
| `jpeg_encode`        | x        | x        | x                    |                      | x             |
| `jpeg_decode`        | x        | x        | x                    |                      | x             |
| `ImageMagick.save`   | x        | x        | x                    |                      | x             |
| `ImageMagick.load`   | x        | x        | x                    |                      | x             |
| `QuartzImageIO.save` | x        | x        | x (`FileIO.Stream`)  |                      | x             |
| `QuartzImageIO.load` | x        | x        | x (`FileIO.Stream`)  |                      | x             |

Notes:

- `x`: supported
- empty: missing/unsupported yet

