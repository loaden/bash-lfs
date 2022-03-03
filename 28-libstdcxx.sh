#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 安排战术
IFS='' read -r -d '' HAVE_WORK_TODO <<EOF
pushd /sources/$(getConf LFS_VERSION)
    PKG_NAME=gcc
    PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
    if [ -z \$PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f \$PKG_PATH/build_cxx_2/_BUILD_DONE ]; then
        mkdir -pv \$PKG_PATH/build_cxx_2
        pushd \$PKG_PATH/build_cxx_2
            ../libstdc++-v3/configure            \
                CXXFLAGS="-g -O2 -D_GNU_SOURCE"  \
                --prefix=/usr                    \
                --disable-multilib               \
                --disable-nls                    \
                --host=\$(uname -m)-lfs-linux-gnu \
                --disable-libstdcxx-pch
            make -j$LFS_BUILD_PROC && make install
            if [ \$? = 0 ]; then
                touch _BUILD_DONE
            else
                exit 1
            fi
        popd
    fi
popd

# 安排完毕
EOF

# 战斗啦
source `dirname ${BASH_SOURCE[0]}`/chroot.sh "$HAVE_WORK_TODO"
