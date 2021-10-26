#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

mkdir -pv $LFS/sources
chmod -v a+wt $LFS/sources
wget http://mirrors.ustc.edu.cn/lfs/lfs-packages/lfs-packages-$(getConf LFS_VERSION).tar --continue --directory-prefix=$LFS/sources
tar -xf $LFS/sources/lfs-packages-$(getConf LFS_VERSION).tar --directory $LFS/sources
pushd $LFS/sources/$(getConf LFS_VERSION)
    md5sum -c md5sums
popd