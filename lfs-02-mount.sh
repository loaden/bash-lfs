#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

mkdir -pv $LFS
mount -v $(getConf LFS_ROOT_PARTITION) $LFS
mkdir -pv $LFS/boot/efi
mount -v $(getConf LFS_EFI_PARTITION) $LFS/boot/efi
mkdir -pv $LFS/home
mount -v $(getConf LFS_HOME_PARTITION) $LFS/home
