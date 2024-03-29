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
fi

# 设置lfs用户可写权限
chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
    x86_64) chown -v lfs $LFS/lib64 ;;
esac

# 先彻底删除
find /home/lfs/ -user lfs -type f -name '*' | xargs rm -vf

# 创建启动脚本
cat > /home/lfs/start.sh <<EOF
set +h
umask 022
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
echo "(lfs)LFS=\$LFS"
echo "(lfs)LC_ALL=\$LC_ALL"
echo "(lfs)LFS_TGT=\$LFS_TGT"
echo "(lfs)PATH=\$PATH"
echo "(lfs)CONFIG_SITE=\$CONFIG_SITE"
env
if [ -f /home/lfs/build.sh ]; then
    source /home/lfs/build.sh
fi
EOF

# 启动脚本权限设置
chown -v lfs:lfs /home/lfs/start.sh
chmod u+x /home/lfs/start.sh

# 创建干净的环境变量
cat > /home/lfs/.bash_profile <<EOF
LFS_PATH=/usr/bin
if [ ! -L /bin ]; then
    LFS_PATH=/bin:\$LFS_PATH;
fi
LFS_PATH=$LFS/tools/bin:\$LFS_PATH
exec env -i USER=lfs HOME=/home/lfs TERM=$TERM PS1='\u:\w\$ ' \
    LFS=$LFS LC_ALL=POSIX LFS_TGT=$(uname -m)-lfs-linux-gnu PATH=\$LFS_PATH \
    CONFIG_SITE=$LFS/usr/share/config.site \
    /bin/bash -c 'set +h && umask 022 && /home/lfs/start.sh'
EOF

chown -v lfs:lfs /home/lfs/.bash_profile
su - lfs
