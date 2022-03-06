#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 配置LFS用户编译任务
if [ "$USER" != "lfs" ]; then
    echo "$LFS_PROJECT/`basename ${BASH_SOURCE[0]}`" > /home/lfs/build.sh
    chown lfs:lfs /home/lfs/build.sh
    su - lfs
    exit
fi

# 来自lfs用户的调用
pushd $LFS/sources/$(getConf LFS_VERSION)
    PKG_NAME=file
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            mkdir build
            pushd build
                ../configure --disable-bzlib      \
                             --disable-libseccomp \
                             --disable-xzlib      \
                             --disable-zlib
                make -j$LFS_BUILD_PROC
            popd
            ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
            make FILE_COMPILE=$(pwd)/build/src/file -j$LFS_BUILD_PROC && make DESTDIR=$LFS install
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
