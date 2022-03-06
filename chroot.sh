#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 创建挂载点
mkdir -pv $LFS/{dev,proc,sys,run}

# 创建初始设备节点
[ -e $LFS/dev/console ] || mknod -m 600 $LFS/dev/console c 5 1
[ -e $LFS/dev/null ]    || mknod -m 666 $LFS/dev/null c 1 3

# 挂载和填充/dev
mount -v --bind /dev $LFS/dev

# 挂载虚拟内核文件系统
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
    mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

# 懒虫，干活了！
sleep 0.1
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    /bin/bash "/task.sh"

# 卸载虚拟内核文件系统
sleep 0.3
umount -lf $LFS/dev/pts
umount -lf $LFS/dev
umount -lf $LFS/proc
umount -lf $LFS/sys
umount -lf $LFS/run
sleep 0.2
