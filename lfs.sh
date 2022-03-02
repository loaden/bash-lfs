#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 确认管理员权限
if [[ $EUID != 0 && $USER != lfs ]]; then
    echo "请打开终端，在脚本前添加 sudo 执行，或者 sudo -s 获得管理员权限后再执行。"
    exit 1
fi

# LFS系统分区挂载路径
export LFS=/mnt/lfs
echo LFS=$LFS

# 本项目路径
LFS_PROJECT=$(dirname `readlink -f ${BASH_SOURCE[0]}`)
if [ ! -f $LFS_PROJECT/lfs.conf ]; then
    LFS_PROJECT=$(dirname `readlink -f $LFS_PROJECT/../`)
fi
export LFS_PROJECT
echo LFS_PROJECT=$LFS_PROJECT

# LFS配置文件路径
export LFS_CONF=$LFS_PROJECT/lfs.conf
echo LFS_CONF=$LFS_CONF

# 并行编译核数
export LFS_BUILD_PROC=$(echo $(nproc) - 1 | bc)
echo LFS_BUILD_PROC=$LFS_BUILD_PROC

function getConf() {
    str=$(cat $LFS_CONF | grep $1)
    ret=${str#*=}
    echo $ret
}
