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
if [ ! -f $LFS/sources/DONE ]; then
    wget http://mirrors.ustc.edu.cn/lfs/lfs-packages/lfs-packages-$(getConf LFS_VERSION).tar --continue --directory-prefix=$LFS/sources
    tar -xf $LFS/sources/lfs-packages-$(getConf LFS_VERSION).tar --directory $LFS/sources
    # FIXME: 11.2-rc1 bug
    mv $LFS/sources/11.2-rc1 $LFS/sources/11.2
    pushd $LFS/sources/$(getConf LFS_VERSION)
        md5sum -c md5sums
        if [ $? = 0 ]; then
            mkdir -v stage{1,2,3,4,5,6}
            touch ../DONE
        fi
    popd
fi
