#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 避免chroot后执行
id lfs >/dev/null 2>&1
if [ $? = 0 ]; then
    source `dirname ${BASH_SOURCE[0]}`/lfs.sh

    # 备份
    if [ ! -f $LFS/sources/lfs-stage3.tar.gz ]; then
        pushd $LFS
            tar --exclude=proc --exclude=sys --exclude=dev --exclude=run --exclude=boot \
                --exclude=home --exclude=tools --exclude=sources --one-file-system \
                -capvf $LFS/sources/lfs-stage3.tar.gz --directory=$LFS *
        popd
    fi

    # 准备chroot
    cp -v ${BASH_SOURCE[0]} $LFS/task.sh
    source `dirname ${BASH_SOURCE[0]}`/chroot.sh
    rm -fv $LFS/task.sh
    exit
fi

# 来自chroot之后的调用
# 清理
ls -lah
rm -rvf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
