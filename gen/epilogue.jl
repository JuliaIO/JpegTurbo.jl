######################################################################################################
# macros from jpeglib.h

jpeg_create_compress(cinfo) =
    jpeg_CreateCompress(cinfo, JPEG_LIB_VERSION, sizeof(jpeg_compress_struct))
jpeg_create_decompress(cinfo) =
    jpeg_CreateDecompress(cinfo, JPEG_LIB_VERSION, sizeof(jpeg_decompress_struct))

######################################################################################################

# rewrite patch: j_decompress_ptr => Ptr{jpeg_decompress_struct}
function jpeg_CreateDecompress(cinfo, version, structsize)
    ccall((:jpeg_CreateDecompress, libjpeg), Cvoid, (Ptr{jpeg_decompress_struct}, Cint, Csize_t), cinfo, version, structsize)
end
