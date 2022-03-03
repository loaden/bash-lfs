#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 配置LFS用户编译任务
if [ "$USER" != "lfs" ]; then
    echo "$LFS_PROJECT/`basename ${BASH_SOURCE[0]}`" > /home/lfs/build.sh
    chown lfs:lfs /home/lfs/build.sh
    su - lfs
    return
fi

# 来自lfs用户的调用
pushd $LFS/sources/$(getConf LFS_VERSION)
    PKG_NAME=binutils
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_2/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed '6009s/$add_dir//' -i ltmain.sh
            mkdir build_2
            pushd build_2
                ../configure                   \
                    --prefix=/usr              \
                    --build=$(../config.guess) \
                    --host=$LFS_TGT            \
                    --disable-nls              \
                    --enable-shared            \
                    --disable-werror           \
                    --enable-64-bit-bfd
                make -j$LFS_BUILD_PROC && make DESTDIR=$LFS install
                if [ $? = 0 ]; then
                    touch _BUILD_DONE
                else
                    exit 1
                fi
            popd
        popd
    fi
popd
