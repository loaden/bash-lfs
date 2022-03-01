#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

mkdir -pv $LFS
if ! mountpoint -q $LFS; then
    mount -v $(getConf LFS_ROOT_PARTITION) $LFS
    grep $LFS /proc/mounts
fi

mkdir -pv $LFS/boot/efi
if ! mountpoint -q $LFS/boot/efi; then
    mount -v $(getConf LFS_EFI_PARTITION) $LFS/boot/efi
    grep $LFS/boot/efi /proc/mounts
fi

mkdir -pv $LFS/home
if ! mountpoint -q $LFS/home; then
    mount -v $(getConf LFS_HOME_PARTITION) $LFS/home
    grep $LFS/home /proc/mounts
fi
