# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "LibVPX"
version = v"1.8.0"

# Collection of sources required to build LibVPX
sources = [
    "https://github.com/webmproject/libvpx/archive/v1.8.0.tar.gz" =>
    "86df18c694e1c06cc8f83d2d816e9270747a0ce6abe316e93a4f4095689373f6",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libvpx-1.8.0/
sed -i 's/cp -p/cp/' build/make/Makefile
mkdir libvpx-build
cd libvpx-build
CROSS=$target
apk add diffutils
apk add yasm
../configure --prefix=$prefix --target=generic-gnu --enable-shared --disable-static
echo "SRC_PATH_BARE=.." >> config.mk
echo "target=libs" >> config.mk
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    # MacOS(:x86_64, compiler_abi=CompilerABI(:gcc4)),
    # FreeBSD(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libvpx", Symbol(""))
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
