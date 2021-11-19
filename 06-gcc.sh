#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)
    tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name gcc-*.tar.*) 2>/dev/null
    cd $(find . -maxdepth 1 -type d -name "gcc-*")

    tar -xf $(find .. -maxdepth 1 -type f -name mpfr-*.tar.*)
    rm -rf mpfr
    mv -v $(find . -maxdepth 1 -type d -name "mpfr-*") mpfr

    tar -xf $(find .. -maxdepth 1 -type f -name gmp-*.tar.*)
    rm -rf gmp
    mv -v $(find . -maxdepth 1 -type d -name "gmp-*") gmp

    tar -xf $(find .. -maxdepth 1 -type f -name mpc-*.tar.*)
    rm -rf mpc
    mv -v $(find . -maxdepth 1 -type d -name "mpc-*") mpc

    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' \
                -i.orig gcc/config/i386/t-linux64
            ;;
    esac

    mkdir -v build
    cd build
    [ ! $DONT_CONFIG ] && ../configure                 \
        --target=$LFS_TGT                              \
        --prefix=$LFS/tools                            \
        --with-glibc-version=2.11                      \
        --with-sysroot=$LFS                            \
        --with-newlib                                  \
        --without-headers                              \
        --enable-initfini-array                        \
        --disable-nls                                  \
        --disable-shared                               \
        --disable-multilib                             \
        --disable-decimal-float                        \
        --disable-threads                              \
        --disable-libatomic                            \
        --disable-libgomp                              \
        --disable-libquadmath                          \
        --disable-libssp                               \
        --disable-libvtv                               \
        --disable-libstdcxx                            \
        --enable-languages=c,c++
    make -j 1
    make install -j 1

    # 完整的内部头文件
    cd ..
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
popd
