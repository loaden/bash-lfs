#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

mkdir -pv $LFS/sources
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
    ln -sv usr/$i $LFS/$i
done

case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo lfs:passwd | /sbin/chpasswd
chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
    x86_64) chown -v lfs $LFS/lib64 ;;
esac

chown -v lfs $LFS/sources

# 一些商业发行版未做文档说明地将 /etc/bash.bashrc 引入 bash 初始化过程。
# 该文件可能修改 lfs 用户的环境，并影响 LFS 关键软件包的构建。
# TODO: 或者unset是更好的选择？
[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.bak

su - lfs
cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 0022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

exit # FIXME: 为什么切换不回root呢？
