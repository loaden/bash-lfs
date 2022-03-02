#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 系统目录
[ -d $LFS/etc ] || mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}
for i in bin lib sbin; do
    if [ ! -L $LFS/$i ]; then
        ln -sv usr/$i $LFS/$i
    fi
done

case $(uname -m) in
    x86_64) [ -d $LFS/lib64 ] || mkdir -pv $LFS/lib64 ;;
esac

# stage1需要的工具目录
[ -d $LFS/tools ] || mkdir -pv $LFS/tools

# 建立LFS专用用户，避免环境污染
id lfs >/dev/null 2>&1
if [ $? != 0 ]; then
    groupadd lfs
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    echo lfs:lfs | chpasswd
    chown -v lfs $LFS/{.,usr{,/*},lib,var,etc,bin,sbin,tools}
    case $(uname -m) in
        x86_64) chown -v lfs $LFS/lib64 ;;
    esac

    chown -v -R lfs $LFS/sources
fi

# 一些商业发行版未做文档说明地将 /etc/bash.bashrc 引入 bash 初始化过程。
# 该文件可能修改 lfs 用户的环境，并影响 LFS 关键软件包的构建。
if [ -e /etc/bash.bashrc ]; then
    mv -v /etc/bash.bashrc /etc/bash.bashrc.bak
fi

# 先彻底删除
rm -rf /home/lfs/.*
rm -rf /home/lfs/*

# 创建bash初始化配置
cat > /home/lfs/.bashrc.tmp <<EOF
set +h
umask 022
LFS=$LFS
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
env | grep -v LS_COLORS
if [ -f /home/lfs/build.sh ]; then
    bash -c "sleep 0.5 && exec /home/lfs/build.sh && exit"
    exit
fi
EOF

cat > /home/lfs/.bash_profile <<EOF
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
exec env -i USER=lfs HOME=/home/lfs TERM=$TERM PS1='\u:\w\$ ' \
    LFS=$LFS LC_ALL=POSIX LFS_TGT=$(uname -m)-lfs-linux-gnu PATH=$LFS/tools/bin:/usr/bin \
    CONFIG_SITE=$LFS/usr/share/config.site \
    /bin/bash -c 'set +h && umask 022 && echo HHHHHHHHHHHHHHHHHHHHHHHHHHHH && env | grep -v LS_COLORS'
EOF

chown -R lfs:lfs /home/lfs/*
su - lfs
