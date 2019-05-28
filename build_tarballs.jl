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
apk add diffutils yasm

export CONFIG_OPTS="--enable-shared --disable-static --as=yasm"
export TARGET=generic-gnu
if [[ "${target}" == i686-linux-* ]]; then
    export CROSS=x86-linux-gcc
elif [[ "${target}" == x86_64-linux-* ]]; then
    export CROSS=x86_64-linux-gcc
elif [[ "${target}" == arm-linux-* ]]; then
    export CROSS=armv7-linux-gcc
elif [[ "${target}" == powerpc64le-linux-* ]]; then
    export CROSS=ppc64le-linux-gcc
elif [[ "${target}" == x86_64-apple-* ]]; then
    export CROSS=x86_64-darwin14-gcc
    export CC=/opt/${target}/bin/${target}-gcc
    export CXX=/opt/${target}/bin/${target}-g++
    export LD=/opt/${target}/bin/${target}-ld
    export TARGET=$CROSS
elif [[ "${target}" == i686-w64-mingw32 ]]; then
    export CROSS=x86-win32-gcc
    export CONFIG_OPTS="--as=yasm"
elif [[ "${target}" == x86_64-w64-mingw32 ]]; then
    export CROSS=x86_64-win64-gcc
    export CONFIG_OPTS="--as=yasm"
elif [[ "${target}" == x86_64-unknown-* ]]; then
    export CROSS=x86_64-unknown-gcc
    export CC=/opt/${target}/bin/${target}-gcc
    export CXX=/opt/${target}/bin/${target}-g++
    export LD=/opt/${target}/bin/${target}-ld
    export CONFIG_OPTS="--enable-shared --disable-static --as=yasm --disable-multithread"
elif [[ "${target}" == aarch64-linux-* ]]; then
    export CROSS=aarch64-linux-gcc
else
    export CROSS=$target
fi

../configure --prefix=$prefix --target=${TARGET} ${CONFIG_OPTS}
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
    FreeBSD(:x86_64),
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
