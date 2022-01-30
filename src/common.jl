jpeg_components(::AbstractArray{T}) where T = jpeg_components(T)
jpeg_components(::Type{CT}) where CT<:Colorant = length(CT)
jpeg_components(::Type{T}) where T<:Number = 1

jpeg_color_space(::AbstractArray{T}) where T = jpeg_color_space(T)
jpeg_color_space(::Type{CT}) where CT<:Gray = LibJpeg.JCS_GRAYSCALE
jpeg_color_space(::Type{CT}) where CT<:RGB = LibJpeg.JCS_RGB
jpeg_color_space(::Type{CT}) where CT<:BGR = LibJpeg.JCS_EXT_BGR
jpeg_color_space(::Type{CT}) where CT<:RGBA = LibJpeg.JCS_EXT_RGBA
jpeg_color_space(::Type{CT}) where CT<:BGRA = LibJpeg.JCS_EXT_BGRA
jpeg_color_space(::Type{CT}) where CT<:ABGR = LibJpeg.JCS_EXT_ABGR
jpeg_color_space(::Type{CT}) where CT<:ARGB = LibJpeg.JCS_EXT_ARGB
