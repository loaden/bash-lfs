#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)
    tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name binutils-*.tar.*) 2>/dev/null
    cd $(find . -maxdepth 1 -type d -name "binutils-*")
    mkdir -v build
    cd build
    [ ! $DONT_CONFIG ] && ../configure  \
        --prefix=$LFS/tools             \
        --with-sysroot=$LFS             \
        --target=$LFS_TGT               \
        --disable-nls                   \
        --disable-werror
    make -j $(getConf LFS_BUILD_PROC)
    make install -j 1
popd
