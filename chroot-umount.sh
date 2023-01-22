#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 卸载虚拟内核文件系统
umount -Rlv $LFS/dev
umount -Rlv $LFS/proc
umount -Rlv $LFS/sys
umount -Rlv $LFS/run
