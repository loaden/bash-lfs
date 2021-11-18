#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pkg_name=binutils
pushd $LFS/sources/$(getConf LFS_VERSION)
    tar -xvf $(find . -maxdepth 1 -type f -name $pkg_name-*.tar.*)
    cd $(find . -maxdepth 1 -type d -name "$pkg_name-*")
    mkdir -v build
    cd build
    ../configure --prefix=$LFS/tools    \
        --with-sysroot=$LFS             \
        --target=$LFS_TGT               \
        --disable-nls                   \
        --disable-werror
    make -j
    make install -j 1
popd
