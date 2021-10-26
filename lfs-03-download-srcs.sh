#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

mkdir -pv $LFS/sources
chmod -v a+wt $LFS/sources
wget --input-file=`dirname ${BASH_SOURCE[0]}`/wget-list --continue --directory-prefix=$LFS/sources
cp `dirname ${BASH_SOURCE[0]}`/md5sums $LFS/sources/md5sums
pushd $LFS/sources
    md5sum -c md5sums
popd
