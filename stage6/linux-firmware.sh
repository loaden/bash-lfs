#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 避免chroot后执行
id lfs >/dev/null 2>&1
if [ $? = 0 ]; then
    source `dirname ${BASH_SOURCE[0]}`/../lfs.sh

    pushd $LFS/sources/$(getConf LFS_VERSION)
        # 删除缓存
        rm -fv wget-*

        # linux-firmware: https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/
        PKG_NAME=linux-firmware
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://mirrors.aliyun.com/linux-kernel/firmware/linux-firmware-20230117.tar.xz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done
    popd

    # 准备chroot
    cp -v ${BASH_SOURCE[0]} $LFS/task.sh
    sed "s/_LFS_VERSION/$(getConf LFS_VERSION)/g" -i $LFS/task.sh
    sed "s/_LFS_BUILD_PROC/$LFS_BUILD_PROC/g" -i $LFS/task.sh
    source `dirname ${BASH_SOURCE[0]}`/../chroot.sh
    rm -fv $LFS/task.sh
    exit
fi

# 来自chroot之后的调用
pushd /sources/_LFS_VERSION
    PKG_NAME=linux-firmware
    PKG_PATH=$(find stage6 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage6
        PKG_PATH=$(find stage6 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            [ $? = 0 ] && make install
            if [ $? = 0 ]; then
                read -p "$PKG_NAME ALL DONE..."
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
