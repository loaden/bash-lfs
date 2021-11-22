#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)
    cd $(find . -maxdepth 1 -type d -name "gcc-*")
    mkdir -v build_cxx
    cd build_cxx
    ../libstdc++-v3/configure           \
        --host=$LFS_TGT                 \
        --build=$(../config.guess)      \
        --prefix=/usr                   \
        --disable-multilib              \
        --disable-nls                   \
        --disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/$(getConf LFS_GCC_VERSION)
    make -j $(getConf LFS_BUILD_PROC)
    make DESTDIR=$LFS install -j 1
popd
