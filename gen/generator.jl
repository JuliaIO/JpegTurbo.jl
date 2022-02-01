using Clang.JLLEnvs
using Clang.Generators
using JpegTurbo_jll

cd(@__DIR__)

include_dir = normpath(JpegTurbo_jll.artifact_dir, "include")


function generate_prologue(options)
    # Macro "#define LIBJPEG_TURBO_VERSION 2.1.0" is not well-defined values
    # for Clang to parse. Thus we manually parse and generate it as prologue.
    function get_jpegturbo_version()
        lines = readlines(joinpath(include_dir, "jconfig.h"))
        prefix = "#define LIBJPEG_TURBO_VERSION "
        version_line = filter(lines) do line
            startswith(line, prefix)
        end[1]
        version_str = strip(split(version_line, prefix)[2])
        return VersionNumber(version_str)
    end

    outfile = options["general"]["prologue_file_path"]
    open(outfile, "w") do io
        println(io, "const LIBJPEG_TURBO_VERSION = v\"$(get_jpegturbo_version())\"")
        println(io)

        # https://github.com/libjpeg-turbo/libjpeg-turbo/blob/14ce28a92d45e4e22b643bd845ba6c543ebcd388/win/jconfig.h.in#L14-L18
        println(io, "const boolean = @static Sys.iswindows() ? Cuchar : Cint")
        println(io)
    end
end

options = load_options(joinpath(@__DIR__, "generator.toml"))

args = get_default_args()
push!(args, "-I$include_dir")

# include <stdio.h> so that `size_t` and `FILE` are defined
system_dirs = map(x->x[9:end], filter(x->startswith(x, "-isystem"), args))
usrinclude_dir = system_dirs[findfirst(endswith("/usr/include"), system_dirs)]
header_stdio = joinpath(usrinclude_dir, "stdio.h")
push!(args, "-include$header_stdio")

generate_prologue(options)

# https://github.com/JuliaInterop/Clang.jl/discussions/373
headers = [
    joinpath(include_dir, "jpeglib.h"),
    joinpath(include_dir, "turbojpeg.h")
]

ctx = create_context(headers, args, options)
build!(ctx, BUILDSTAGE_NO_PRINTING)

rewrite_j_decompress_ptr!(::String) = nothing
function rewrite_j_decompress_ptr!(e::Expr)
    # We would expect `const j_decompress_ptr = Ptr{jpeg_decompress_struct}`.
    # However, since Julia doesn't support forward declaration, thus Clang (v0.15.5)
    # generates a helper struct `__JL_jpeg_decompress_struct` with associated
    # `const j_decompress_ptr = Ptr{__JL_jpeg_decompress_struct}`, a lot of
    # related ccall methods needs a rewrite patch
    # `j_decompress_ptr => Ptr{jpeg_decompress_struct}` to make things work.

    if e.head == :block
        return foreach(rewrite_j_decompress_ptr!, e.args)
    end
    if e.head == :function
        return rewrite_j_decompress_ptr!(e.args[2])
    end

    if e.head == :call && e.args[1] == :ccall
        @assert e.head == :call
        @assert e.args[1] == :ccall
        if any(isequal(:j_decompress_ptr), e.args[4].args)
            rtypes = Expr(:tuple, map(e.args[4].args) do e
                e == :j_decompress_ptr && return :(Ptr{jpeg_decompress_struct})
                return e
            end...)
            old = copy(e)
            e.args[4] = rtypes
            @info "ccall rewrite for j_decompress_ptr" old new=e
        end
    end
    return
end

function rewrite!(dag::ExprDAG)
    for node in get_nodes(dag)
        for expr in get_exprs(node)
            rewrite_j_decompress_ptr!(expr)
        end
    end
end

rewrite!(ctx.dag)
build!(ctx, BUILDSTAGE_PRINTING_ONLY)
