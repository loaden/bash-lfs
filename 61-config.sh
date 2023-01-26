#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 避免chroot后执行
id lfs >/dev/null 2>&1
if [ $? = 0 ]; then
    source `dirname ${BASH_SOURCE[0]}`/lfs.sh
    cp -v ${BASH_SOURCE[0]} $LFS/task.sh
    sed "s/_LFS_VERSION/$(getConf LFS_VERSION)/g" -i $LFS/task.sh
    sed "s/_LFS_BUILD_PROC/$LFS_BUILD_PROC/g" -i $LFS/task.sh
    source `dirname ${BASH_SOURCE[0]}`/chroot.sh
    rm -fv $LFS/task.sh
    exit
fi

# 来自chroot之后的调用

# 网络配置
cat > /etc/systemd/network/20-wired.network << EOF
[Match]
Name=en*

[Network]
DHCP=yes
EOF

cat > /etc/systemd/network/25-wireless.network << EOF
[Match]
Name=wl*

[Network]
DHCP=ipv4
EOF

# 主机名
echo "lucky" > /etc/hostname

# 时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 语言
localedef -i zh_CN -f UTF-8 zh_CN.UTF-8
cat > /etc/locale.conf << "EOF"
LANG=zh_CN.UTF-8
EOF

# 创建 /etc/inputrc
cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8-bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

# 创建 /etc/shells
cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

# systemd
systemctl preset-all --preset-mode=enable-only
systemctl disable systemd-sysupdate

# 创建 /etc/fstab
cat > /etc/fstab << "EOF"
# <file system>  <mount point>  <type>  <options>            <dump>  <pass>
/dev/nvme0n1p1   /boot/efi      vfat    umask=0077            0      0
/dev/nvme0n1p6   /              btrfs   noatime,subvol=@lfs   0      0
/dev/nvme0n1p6   /home          btrfs   noatime,subvol=@home  0      0
EOF

# 用户 shell
cat > /root/.bashrc << "EOF"
[[ $- != *i* ]] && return
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
EOF
cat > /root/.bash_profile << "EOF"
[[ -f ~/.bashrc ]] && . ~/.bashrc
EOF