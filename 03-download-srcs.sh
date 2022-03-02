#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

if [ ! -d $LFS/sources ]; then
    mkdir -pv $LFS/sources
    chmod -v a+wt $LFS/sources
fi

if [ ! -f $LFS/sources/DONE ]; then
    wget http://mirrors.ustc.edu.cn/lfs/lfs-packages/lfs-packages-$(getConf LFS_VERSION).tar --continue --directory-prefix=$LFS/sources
    tar -xf $LFS/sources/lfs-packages-$(getConf LFS_VERSION).tar --directory $LFS/sources
    pushd $LFS/sources/$(getConf LFS_VERSION)
        md5sum -c md5sums
        [ $? = 0 ] && touch $LFS/sources/DONE
    popd
fi
