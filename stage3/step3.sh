#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step3
# stage3重新运行失败的测试，看看有没有奇迹发生
#

if [ ! -f $LFS/task.sh ]; then
    source `dirname ${BASH_SOURCE[0]}`/../lfs.sh
    cp -v ${BASH_SOURCE[0]} $LFS/task.sh
    sed "s/_LFS_VERSION/$(getConf LFS_VERSION)/g" -i $LFS/task.sh
    sed "s/_LFS_BUILD_PROC/$LFS_BUILD_PROC/g" -i $LFS/task.sh
    source `dirname ${BASH_SOURCE[0]}`/../chroot.sh
    rm -fv $LFS/task.sh
    exit
fi

# 来自chroot之后的调用
pushd /sources/_LFS_VERSION
    PKG_NAME=libtool
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check
            if [ $? = 0 ]; then
                read -p "竟然成功了！"
            else
                pwd
                read -p "FIXME：跳过大量的libtool测试失败，原因未知"
            fi
        popd
    fi
popd
