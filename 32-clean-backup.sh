#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 安排战术
IFS='' read -r -d '' HAVE_WORK_TODO <<EOF
# 清理
rm -rf /usr/share/{info,man,doc}/*
find /usr/{lib,libexec} -name \*.la -delete
rm -rf /tools
EOF

# 战斗啦
source `dirname ${BASH_SOURCE[0]}`/chroot.sh "$HAVE_WORK_TODO"

# 备份
umount -lf $LFS/home
pushd $LFS
    tar --exclude=boot --exclude=home -capvf $LFS_PROJECT/lfs-stage2-$(getConf LFS_VERSION).tar.zst .
popd
