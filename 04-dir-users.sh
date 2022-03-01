#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 系统目录
mkdir -pv $LFS/sources
mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

for i in bin lib sbin; do
    ln -sfv usr/$i $LFS/$i
done

case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 ;;
esac

# stage1需要的工具目录
mkdir -pv $LFS/tools

# 建立LFS专用用户，避免环境污染
export LFS_USER=lfs
id $LFS_USER >/dev/null 2>&1
if [ $? != 0 ]; then
    groupadd $LFS_USER
    useradd -s /bin/bash -g $LFS_USER -m -k /dev/null $LFS_USER
    echo $LFS_USER:$LFS_USER | /sbin/chpasswd
    chown -v $LFS_USER $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
    case $(uname -m) in
        x86_64) chown -v $LFS_USER $LFS/lib64 ;;
    esac

    chown -v $LFS_USER $LFS/sources
fi

# 一些商业发行版未做文档说明地将 /etc/bash.bashrc 引入 bash 初始化过程。
# 该文件可能修改 $LFS_USER 用户的环境，并影响 LFS 关键软件包的构建。
if [ -e /etc/bash.bashrc ]; then
    mv -v /etc/bash.bashrc /etc/bash.bashrc.bak
fi

# 该设置为$LFS_USER用户所配置，后面的编译都要在$LFS_USER用户下进行
export LFS_HOME=/home/$LFS_USER
echo LFS_HOME=$LFS_HOME

cat > $LFS_HOME/.bashrc <<EOF
set +h
umask 0022
LFS=$LFS
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
cd $LFS_PROJECT
env | grep -v LS_COLORS
EOF

cat > ~/.bash_profile <<EOF
exec env -i USER=$LFS_USER HOME=$LFS_HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

chown $LFS_USER:$LFS_USER $LFS_HOME/.bash*
su - $LFS_USER
