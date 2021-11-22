#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)
    # M4
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "m4-*")
    tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name m4-*.tar.*) 2>/dev/null
    build_dir=$(find . -maxdepth 1 -type d -name "m4-*")/build
    mkdir -v $build_dir
    pushd $build_dir
        ../configure --prefix=/usr   \
            --host=$LFS_TGT         \
            --build=$(../build-aux/config.guess)
        make -j $(getConf LFS_BUILD_PROC)
        make DESTDIR=$LFS install -j 1
        [ $? ] && read -p "编译出错？任何键继续..." -n 1
    popd


    # Ncurses
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "ncurses-*")
    tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name ncurses-*.tar.*) 2>/dev/null
    pushd $(find . -maxdepth 1 -type d -name "ncurses-*")
        sed -i s/mawk// configure
        mkdir -v build_tic
        pushd build_tic
            ../configure
            make -C include
            make -C progs tic
        popd

        mkdir -v build
        pushd build
            ../configure --prefix=/usr          \
                --host=$LFS_TGT                 \
                --build=$(../config.guess)      \
                --mandir=/usr/share/man         \
                --with-manpage-format=normal    \
                --with-shared                   \
                --without-debug                 \
                --without-ada                   \
                --without-normal                \
                --enable-widec
            make -j $(getConf LFS_BUILD_PROC)
            make DESTDIR=$LFS TIC_PATH=$(pwd)/../build_tic/progs/tic install
            [ $? ] && read -p "编译出错？任何键继续..." -n 1
            echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
        popd
    popd
popd
