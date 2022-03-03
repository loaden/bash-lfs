#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)

    if false; then

    # Coreutils
    echo Coreutils... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "coreutils-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name coreutils-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "coreutils-*")
        [ ! $DONT_CONFIG ] && [ -f PATCHED ] && patch -p1 -R < $(find .. -maxdepth 1 -type f -name coreutils-*.patch)
        [ ! $DONT_CONFIG ] && patch -p1 < $(find .. -maxdepth 1 -type f -name coreutils-*.patch)
        [ ! $DONT_CONFIG ] && touch PATCHED
        [ ! $DONT_CONFIG ] && sleep 3

        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure          \
                --prefix=/usr                           \
                --host=$LFS_TGT                         \
                --build=$(../build-aux/config.guess)    \
                --enable-install-program=hostname       \
                --enable-no-install-program=kill,uptime
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
            mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
            mkdir -pv $LFS/usr/share/man/man8
            mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
            sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
        popd
    popd
    read -p "Coreutils 编译结束，任意键继续..." -n 1

    # Diffutils
    echo Diffutils... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "diffutils-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name diffutils-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "diffutils-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --host=$LFS_TGT
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Diffutils 编译结束，任意键继续..." -n 1

    # File
    echo File... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "file-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name file-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "file-*")
        mkdir -v host_build
        pushd host_build
            [ ! $DONT_CONFIG ] && ../configure  \
                --disable-bzlib                 \
                --disable-libseccomp            \
                --disable-xzlib                 \
                --disable-zlib
            make -j $LFS_BUILD_PROC
        popd
        [ ! $DONT_CONFIG ] && sleep 3
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --host=$LFS_TGT                 \
                --build=$(./config.guess)
            make FILE_COMPILE=$(pwd)/../host_build/src/file
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "File 编译结束，任意键继续..." -n 1

    # Findutils
    echo Findutils... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "findutils-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name findutils-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "findutils-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --localstatedir=/var/lib/locate \
                --host=$LFS_TGT                 \
                --build=$(../build-aux/config.guess)
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Findutils 编译结束，任意键继续..." -n 1

    # Gawk
    echo Gawk... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "gawk-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name gawk-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "gawk-*")
        sed -i 's/extras//' Makefile.in
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --host=$LFS_TGT                 \
                --build=$(../config.guess)
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Gawk 编译结束，任意键继续..." -n 1

    # Grep
    echo Grep... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "grep-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name grep-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "grep-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --host=$LFS_TGT                 \
                --build=$(../config.guess)
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Grep 编译结束，任意键继续..." -n 1

    # Gzip
    echo Gzip... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "gzip-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name gzip-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "gzip-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --host=$LFS_TGT                 \
                --build=$(../config.guess)
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Gzip 编译结束，任意键继续..." -n 1

    # Make
    echo Make... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "make-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name make-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "make-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --without-guile                 \
                --host=$LFS_TGT                 \
                --build=$(../build-aux/config.guess)
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Make 编译结束，任意键继续..." -n 1

    # Patch
    echo Patch... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "patch-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name patch-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "patch-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --host=$LFS_TGT                 \
                --build=$(../build-aux/config.guess)
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Patch 编译结束，任意键继续..." -n 1

    # Sed
    echo Sed... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "sed-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name sed-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "sed-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --host=$LFS_TGT                 \
                --build=$(../build-aux/config.guess)
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Sed 编译结束，任意键继续..." -n 1

    # Tar
    echo Tar... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "tar-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name tar-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "sed-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --host=$LFS_TGT                 \
                --build=$(../build-aux/config.guess)
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Tar 编译结束，任意键继续..." -n 1

    # Xz
    echo Xz... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "xz-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name xz-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "xz-*")
        mkdir -v build
        pushd build
            [ ! $DONT_CONFIG ] && ../configure      \
                --prefix=/usr                       \
                --host=$LFS_TGT                     \
                --build=$(../build-aux/config.guess)\
                --disable-static                    \
                --docdir=/usr/share/doc/xz-5.2.5
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
        popd
    popd
    read -p "Xz 编译结束，任意键继续..." -n 1

    # Binutils 2
    echo Binutils 2... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "binutils-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name binutils-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "binutils-*")
        [ ! $DONT_CONFIG ] && [ -f PATCHED ] && patch -p1 -R < $(find .. -maxdepth 1 -type f -name binutils-*.patch)
        [ ! $DONT_CONFIG ] && patch -p1 < $(find .. -maxdepth 1 -type f -name binutils-*.patch)
        [ ! $DONT_CONFIG ] && touch PATCHED
        [ ! $DONT_CONFIG ] && sleep 3
        mkdir -v build2
        pushd build2
            [ ! $DONT_CONFIG ] && ../configure  \
                --prefix=/usr                   \
                --build=$(../config.guess)      \
                --host=$LFS_TGT                 \
                --disable-nls                   \
                --enable-shared                 \
                --disable-werror                \
                --enable-64-bit-bfd
            make -j $LFS_BUILD_PROC
            make DESTDIR=$LFS install -j 1
            install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib
        popd
    popd
    read -p "Binutils 2 编译结束，任意键继续..." -n 1

    # GCC 2
    echo GCC 2... && sleep 2
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "gcc-*")
    [ ! $DONT_CONFIG ] && tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name gcc-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "gcc-*")
        [ ! $DONT_CONFIG ] && tar -xf $(find .. -maxdepth 1 -type f -name mpfr-*.tar.*)
        [ ! $DONT_CONFIG ] && rm -rf mpfr
        [ ! $DONT_CONFIG ] && mv -v $(find . -maxdepth 1 -type d -name "mpfr-*") mpfr

        [ ! $DONT_CONFIG ] && tar -xf $(find .. -maxdepth 1 -type f -name gmp-*.tar.*)
        [ ! $DONT_CONFIG ] && rm -rf gmp
        [ ! $DONT_CONFIG ] && mv -v $(find . -maxdepth 1 -type d -name "gmp-*") gmp

        [ ! $DONT_CONFIG ] && tar -xf $(find .. -maxdepth 1 -type f -name mpc-*.tar.*)
        [ ! $DONT_CONFIG ] && rm -rf mpc
        [ ! $DONT_CONFIG ] && mv -v $(find . -maxdepth 1 -type d -name "mpc-*") mpc

        case $(uname -m) in
            x86_64)
                sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
            ;;
        esac

        mkdir -v build2
        pushd build2
            mkdir -pv $LFS_TGT/libgcc
            ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
            [ ! $DONT_CONFIG ] && ../configure  \
                --build=$(../config.guess)      \
                --host=$LFS_TGT                 \
                --prefix=/usr                   \
                CC_FOR_TARGET=$LFS_TGT-gcc      \
                --with-build-sysroot=$LFS       \
                --enable-initfini-array         \
                --disable-nls                   \
                --disable-multilib              \
                --disable-decimal-float         \
                --disable-libatomic             \
                --disable-libgomp               \
                --disable-libquadmath           \
                --disable-libssp                \
                --disable-libvtv                \
                --disable-libstdcxx             \
                --enable-languages=c,c++
            make -j 2
            make DESTDIR=$LFS install -j 1
            ln -sv gcc $LFS/usr/bin/cc
        popd
    popd
    read -p "GCC 2 编译结束，任意键继续..." -n 1

    else

    fi
popd
