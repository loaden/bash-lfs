#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 绑定挂载和填充 /dev
mount -v --bind /dev $LFS/dev

# 挂载虚拟内核文件系统
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
    mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

# 手动chroot修复
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    /bin/bash --login

# 卸载虚拟内核文件系统
umount -Rlv $LFS/dev
umount -Rlv $LFS/proc
umount -Rlv $LFS/sys
umount -Rlv $LFS/run
