#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 避免chroot后执行
id lfs >/dev/null 2>&1
if [ $? = 0 ]; then
    source `dirname ${BASH_SOURCE[0]}`/../lfs.sh

    pushd $LFS/sources/$(getConf LFS_VERSION)
        # 删除缓存
        rm -fv wget-*

        # btrfs-progs：https://linuxfromscratch.org/blfs/view/stable-systemd/postlfs/btrfs-progs.html
        PKG_NAME=btrfs-progs
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://www.kernel.org/pub/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v5.19.tar.xz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # btrfs-progs 依赖：https://linuxfromscratch.org/blfs/view/stable-systemd/general/lzo.html
        PKG_NAME=lzo
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
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
    PKG_NAME=lzo
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr            \
                --enable-shared                  \
                --disable-static                 \
                --docdir=/usr/share/doc/lzo-2.10

            [ $? = 0 ] && make
            [ $? = 0 ] && make check && read -p "$PKG_NAME CHECK DONE..."
            [ $? = 0 ] && make test && read -p "$PKG_NAME TEST DONE..."
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

pushd /sources/_LFS_VERSION
    PKG_NAME=btrfs-progs
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr --disable-documentation

            [ $? = 0 ] && make && make fssum
            if [ $? = 0 ]; then
                # pushd tests
                #     ./fsck-tests.sh
                #     ./mkfs-tests.sh
                #     ./cli-tests.sh
                #     ./convert-tests.sh
                #     ./misc-tests.sh
                #     ./fuzz-tests.sh
                #     read -p "$PKG_NAME TEST DONE..."
                # popd
            fi
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
