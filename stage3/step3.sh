#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step3
# stage3重新运行失败的测试，看看有没有奇迹发生
#

pushd /sources/_LFS_VERSION
    PKG_NAME=libtool
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
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
