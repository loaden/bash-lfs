#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "linux-*")
    tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name linux-*.tar.*) 2>/dev/null
    cd $(find . -maxdepth 1 -type d -name "linux-*")
    make mrproper
    make headers
    find usr/include -name '.*' -delete
    rm usr/include/Makefile
    cp -rv usr/include $LFS/usr
popd
