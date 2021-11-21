#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

mkdir -pv $LFS/sources
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
    ln -sfv usr/$i $LFS/$i
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

# 该设置为lfs用户所配置，后面的编译都要在lfs用户下进行
export LFS_PROJECT=$(dirname `readlink -f $0`)
export LFS_HOME=/mnt/lfs
echo LFS_PROJECT=$LFS_PROJECT
echo LFS_HOME=$LFS_HOME
rm -f $LFS_HOME/config.sh
rm -f $LFS_HOME/.bash*

cat > $LFS_HOME/config.sh <<EOF
#/bin/bash

cat > ~/.bashrc <<END
set +h
umask 0022
LFS=$LFS
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
cd $LFS_PROJECT
END

cat > ~/.bash_profile <<END
exec env -i HOME=$LFS_HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
END
EOF

chown lfs:lfs $LFS_HOME/config.sh
chmod u+x $LFS_HOME/config.sh

su - lfs -w LFS -w LFS_PROJECT -c "~/config.sh"
