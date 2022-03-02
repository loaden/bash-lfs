#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 配置LFS用户编译任务
if [ "$USER" != "lfs" ]; then
    echo "$LFS_PROJECT/`basename ${BASH_SOURCE[0]}`" > /home/lfs/build.sh
    chown lfs:lfs /home/lfs/build.sh
    su - lfs
    exit
fi

# 来自lfs用户的调用
pushd $LFS/sources/$(getConf LFS_VERSION)
    PKG_NAME=gcc
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name $PKG_NAME-*.tar.*)
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            tar -xpvf $(find .. -maxdepth 1 -type f -name mpfr-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "mpfr-*") mpfr
            tar -xpvf $(find .. -maxdepth 1 -type f -name gmp-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "gmp-*") gmp
            tar -xpvf $(find .. -maxdepth 1 -type f -name mpc-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "mpc-*") mpc
            case $(uname -m) in
                 x86_64)
                    sed -e '/m64=/s/lib64/lib/' \
                        -i.orig gcc/config/i386/t-linux64
                        ;;
            esac
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            ../configure                                            \
                --target=$LFS_TGT                                   \
                --prefix=$LFS/tools                                 \
                --with-glibc-version=$(getConf LFS_GLIBC_VERSION)   \
                --with-sysroot=$LFS                                 \
                --with-newlib                                       \
                --without-headers                                   \
                --enable-initfini-array                             \
                --disable-nls                                       \
                --disable-shared                                    \
                --disable-multilib                                  \
                --disable-decimal-float                             \
                --disable-threads                                   \
                --disable-libatomic                                 \
                --disable-libgomp                                   \
                --disable-libquadmath                               \
                --disable-libssp                                    \
                --disable-libvtv                                    \
                --disable-libstdcxx                                 \
                --enable-languages=c,c++
            make -j$LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                cat ../gcc/limitx.h ../gcc/glimits.h ../gcc/limity.h \
                    > `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
                ls -lh `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
                touch _BUILD_DONE
            else
                exit 1
            fi
        popd
    fi
popd
