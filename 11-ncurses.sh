#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 配置LFS用户编译任务
if [ "$USER" != "lfs" ]; then
    cp "$LFS_PROJECT/`basename ${BASH_SOURCE[0]}`" /home/lfs/build.sh
    cp "$LFS_PROJECT/lfs.sh" /home/lfs/
    cp "$LFS_PROJECT/lfs.conf" /home/lfs/
    chown lfs:lfs /home/lfs/build.sh
    chown lfs:lfs /home/lfs/lfs.sh
    chown lfs:lfs /home/lfs/lfs.conf
    [ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
    su - lfs
    [ ! -e /etc/bash.bashrc.NOUSE ] || mv -v /etc/bash.bashrc.NOUSE /etc/bash.bashrc
    rm -f /home/lfs/build.sh
    rm -f /home/lfs/lfs.sh
    rm -f /home/lfs/lfs.conf
    exit
fi

# 来自lfs用户的调用
pushd $LFS/sources/$(getConf LFS_VERSION)
    PKG_NAME=ncurses
    PKG_PATH=$(find stage2 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage2
        PKG_PATH=$(find stage2 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            # 保证在配置时优先查找 gawk 命令
            sed -i s/mawk// configure
            # 在宿主系统构建“tic”程序
            mkdir build
            pushd build
                ../configure
                make -C include
                make -C progs tic
            popd
            sleep 5
            # 编译
            ./configure --prefix=/usr        \
                --host=$LFS_TGT              \
                --build=$(./config.guess)    \
                --mandir=/usr/share/man      \
                --with-manpage-format=normal \
                --with-shared                \
                --without-normal             \
                --with-cxx-shared            \
                --without-debug              \
                --without-ada                \
                --disable-stripping          \
                --enable-widec
            make -j$LFS_BUILD_PROC && make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
            if [ $? = 0 ]; then
                echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
