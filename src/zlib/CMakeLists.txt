add_library(ccache_bundled_zlib
    adler32.c
    crc32.c
    crc32.h
    deflate.c
    deflate.h
    gzclose.c
    gzguts.h
    gzlib.c
    gzread.c
    gzwrite.c
    inffast.c
    inffast.h
    inffixed.h
    inflate.c
    inflate.h
    inftrees.c
    inftrees.h
    trees.c
    trees.h
    zconf.h
    zlib.h
    zutil.c
    zutil.h
)

_force_include_headers(ccache_bundled_zlib ${CCACHE_CONFIG_H})

# Create alias for the zlib target that matches the output of the FindZLIB module
add_library(ZLIB::ZLIB ALIAS ccache_bundled_zlib)
