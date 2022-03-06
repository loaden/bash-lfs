#!/bin/bash
# QQ群：111601117、钉钉群：35948877

if [ ! -f $LFS/task.sh ]; then
    source `dirname ${BASH_SOURCE[0]}`/lfs.sh
    cp -v ${BASH_SOURCE[0]} $LFS/task.sh
    sed "s/_LFS_VERSION/$(getConf LFS_VERSION)/g" -i $LFS/task.sh
    source `dirname ${BASH_SOURCE[0]}`/chroot.sh
    rm -fv $LFS/task.sh
    # 备份
    pushd $LFS
        BAK_FILE=$LFS_PROJECT/lfs-stage2-$(getConf LFS_VERSION).tar.zst
        if [ ! -f $BAK_FILE ]; then
            tar --exclude=boot --exclude=home -capvf $BAK_FILE .
        fi
    popd
    exit
fi

# 来自chroot之后的调用
# 清理
rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools
