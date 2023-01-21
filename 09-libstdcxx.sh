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
    PKG_NAME=gcc
    PKG_PATH=$(find stage1 -maxdepth 1 -type d -name "$PKG_NAME-*")

    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_cxx/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_cxx
        pushd $PKG_PATH/build_cxx
            ../libstdc++-v3/configure           \
                --host=$LFS_TGT                 \
                --build=$(../config.guess)      \
                --prefix=/usr                   \
                --disable-multilib              \
                --disable-nls                   \
                --disable-libstdcxx-pch         \
                --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/12.2.0
            make -j$LFS_BUILD_PROC && make DESTDIR=$LFS install
            if [ $? = 0 ]; then
                # 移除对交叉编译有害的 libtool 档案文件
                rm -v $LFS/usr/lib/lib{stdc++,stdc++fs,supc++}.la
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
