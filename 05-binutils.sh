#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "binutils-*")
    tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name binutils-*.tar.*) 2>/dev/null
    cd $(find . -maxdepth 1 -type d -name "binutils-*")
    [ -f PATCHED ] && patch -p1 -R < $(find .. -maxdepth 1 -type f -name binutils-*.patch)
    patch -p1 < $(find .. -maxdepth 1 -type f -name binutils-*.patch)
    touch PATCHED
    mkdir -v build
    cd build
    [ ! $DONT_CONFIG ] && ../configure  \
        --prefix=$LFS/tools             \
        --with-sysroot=$LFS             \
        --target=$LFS_TGT               \
        --disable-nls                   \
        --disable-werror
    make -j $LFS_BUILD_PROC
    make install -j 1
popd
