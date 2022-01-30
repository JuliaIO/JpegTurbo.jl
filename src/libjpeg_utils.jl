"""
    versioninfo()

Print information about the libjpeg-turbo in use.
"""
function versioninfo()
    println("libjpeg version: ", LibJpeg.JPEG_LIB_VERSION)
    println("libjpeg-turbo version: ", LibJpeg.LIBJPEG_TURBO_VERSION)
    println("bit mode: ", LibJpeg.BITS_IN_JSAMPLE)
    println("SIMD: ", LibJpeg.WITH_SIMD == 1 ? "enabled" : "disabled")
end
