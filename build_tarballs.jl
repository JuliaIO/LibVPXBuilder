# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "LibVPX"
version = v"5.0.0"

# Collection of sources required to build LibVPX
sources = [
    "https://github.com/webmproject/libvpx/archive/v1.7.0/libvpx-1.7.0.tar.gz" =>
    "1fec931eb5c94279ad219a5b6e0202358e94a93a90cfb1603578c326abfc1238",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd libvpx-1.7.0/
sed -i 's/cp -p/cp/' build/make/Makefile
mkdir libvpx-build
cd libvpx-build
CROSS=$target
apk add diffutils
../configure --prefix=$prefix --target=generic-gnu --enable-shared --disable-static
echo "SRC_PATH_BARE=.." >> config.mk
echo "target=libs" >> config.mk
make -j${nproc}
make install

"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libvpx", Symbol(""))
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/jpsamaroo/YasmBuilder/releases/download/v1.3.0-pre/build_YasmBuilder.v1.3.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

