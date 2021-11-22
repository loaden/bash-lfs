#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "glibc-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name glibc-*.tar.*) 2>/dev/null
    cd $(find . -maxdepth 1 -type d -name "glibc-*")
    [ ! $DONT_CONFIG ] && [ -f PATCHED ] && patch -p1 -R < $(find .. -maxdepth 1 -type f -name glibc-*.patch)
    [ ! $DONT_CONFIG ] && patch -p1 < $(find .. -maxdepth 1 -type f -name glibc-*.patch)
    [ ! $DONT_CONFIG ] && touch PATCHED

    mkdir -v build
    cd build

    case $(uname -m) in
        i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
    esac

    echo "rootsbindir=/usr/sbin" > configparms

    [ ! $DONT_CONFIG ] && ../configure      \
        --prefix=/usr                       \
        --host=$LFS_TGT                     \
        --build=$(../scripts/config.guess)  \
        --enable-kernel=3.2                 \
        --with-headers=$LFS/usr/include     \
        libc_cv_slibdir=/usr/lib
    make -j $LFS_BUILD_PROC
    make DESTDIR=$LFS install

    sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
    echo 'int main(){}' > dummy.c
    $LFS_TGT-gcc dummy.c
    readelf -l a.out | grep '/ld-linux'
    $LFS/tools/libexec/gcc/$LFS_TGT/$(getConf LFS_GCC_VERSION)/install-tools/mkheaders
    rm -v dummy.c a.out
    cat `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h > ~/glibc_limits.h
    diff ~/gcc_limits.h ~/glibc_limits.h
popd
