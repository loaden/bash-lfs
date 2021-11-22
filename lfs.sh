#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

# 确认管理员权限
if [[ $EUID != 0 && $USER != lfs ]]; then
    echo "请打开终端，在脚本前添加 sudo 执行，或者 sudo -s 获得管理员权限后再执行。"
    exit 1
fi

export LFS=/mnt/lfs
echo LFS=$LFS
export LFS_CONF=$(dirname `readlink -f $0`)/lfs.conf
echo LFS_CONF=$LFS_CONF
export LFS_BUILD_PROC=$(echo $(nproc) - 1 | bc)
echo LFS_BUILD_PROC=$LFS_BUILD_PROC

function getConf() {
    str=$(cat $LFS_CONF | grep $1)
    ret=${str#*=}
    echo $ret
}
