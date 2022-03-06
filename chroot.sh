#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 创建挂载点
mkdir -pv $LFS/{dev,proc,sys,run}

# 创建初始设备节点
[ -e $LFS/dev/console ] || mknod -m 600 $LFS/dev/console c 5 1
[ -e $LFS/dev/null ]    || mknod -m 666 $LFS/dev/null c 1 3

# 挂载
mount -v --types proc /proc $LFS/proc
mount -v --rbind /sys $LFS/sys
mount -v --make-rslave $LFS/sys
mount -v --rbind /dev $LFS/dev
mount -v --make-rslave $LFS/dev
mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
    mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

# 懒虫，干活了！
sleep 0.2
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/usr/bin:/usr/sbin     \
    /bin/bash -c "set +h &&
                  umask 022 &&
                  env &&
                  /task.sh"

# 卸载虚拟内核文件系统
sleep 0.3
umount -lfv $LFS/dev/pts
umount -lfv $LFS/dev
umount -lfv $LFS/proc
umount -lfv $LFS/sys
umount -lfv $LFS/run
sleep 0.2
