#!/bin/bash
# QQ群：111601117、钉钉群：35948877

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
export LFS_USER=lfs
groupadd $LFS_USER
useradd -s /bin/bash -g $LFS_USER -m -k /dev/null $LFS_USER
echo $LFS_USER:$LFS_USER | /sbin/chpasswd
chown -v $LFS_USER $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
    x86_64) chown -v $LFS_USER $LFS/lib64 ;;
esac

chown -v $LFS_USER $LFS/sources

# 一些商业发行版未做文档说明地将 /etc/bash.bashrc 引入 bash 初始化过程。
# 该文件可能修改 $LFS_USER 用户的环境，并影响 LFS 关键软件包的构建。
# TODO: 或者unset是更好的选择？
[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.bak

# 该设置为$LFS_USER用户所配置，后面的编译都要在$LFS_USER用户下进行
export LFS_PROJECT=$(dirname `readlink -f $0`)
export LFS_HOME=/home/$LFS_USER
echo LFS_PROJECT=$LFS_PROJECT
echo LFS_HOME=$LFS_HOME
rm -f $LFS_HOME/config.sh
rm -f $LFS_HOME/.bash*
sleep 0.5

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
env
END

cat > ~/.bash_profile <<END
exec env -i USER=$LFS_USER HOME=$LFS_HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
END
EOF

chown $LFS_USER:$LFS_USER $LFS_HOME/config.sh
chmod u+x $LFS_HOME/config.sh

su - $LFS_USER -w LFS -w LFS_PROJECT -c "~/config.sh"
