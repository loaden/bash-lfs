#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

if [ ! -d $LFS/sources ]; then
    mkdir -pv $LFS/sources
    chmod -v a+wt $LFS/sources
    chown -v lfs $LFS/sources
fi

# 配置LFS用户编译任务
if [ "$USER" != "lfs" ]; then
    echo "$LFS_PROJECT/`basename ${BASH_SOURCE[0]}`" > /home/lfs/build.sh
    chown lfs:lfs /home/lfs/build.sh
    su - lfs
    return
fi

# 来自lfs用户的调用
if [ ! -f $LFS/sources/DONE ]; then
    wget http://mirrors.ustc.edu.cn/lfs/lfs-packages/lfs-packages-$(getConf LFS_VERSION).tar --continue --directory-prefix=$LFS/sources
    tar -xf $LFS/sources/lfs-packages-$(getConf LFS_VERSION).tar --directory $LFS/sources
    pushd $LFS/sources/$(getConf LFS_VERSION)
        md5sum -c md5sums
        [ $? = 0 ] && touch $LFS/sources/DONE
    popd
fi
