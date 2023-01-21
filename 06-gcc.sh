#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 配置LFS用户编译任务
if [ "$USER" != "lfs" ]; then
    cp "$LFS_PROJECT/`basename ${BASH_SOURCE[0]}`" /home/lfs/build.sh
    cp "$LFS_PROJECT/lfs.sh" /home/lfs/
    cp "$LFS_PROJECT/lfs.conf" /home/lfs/
    chown lfs:lfs /home/lfs/build.sh
    chown lfs:lfs /home/lfs/lfs.sh
    chown lfs:lfs /home/lfs/lfs.conf
    [ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
    su - lfs
    [ ! -e /etc/bash.bashrc.NOUSE ] || mv -v /etc/bash.bashrc.NOUSE /etc/bash.bashrc
    rm -f /home/lfs/build.sh
    rm -f /home/lfs/lfs.sh
    rm -f /home/lfs/lfs.conf
    exit
fi

# 来自lfs用户的调用
pushd $LFS/sources/$(getConf LFS_VERSION)
    PKG_NAME=gcc
    PKG_PATH=$(find stage1 -maxdepth 1 -type d -name "$PKG_NAME-*")

    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage1
        PKG_PATH=$(find stage1 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name mpfr-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "mpfr-*") mpfr
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name gmp-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "gmp-*") gmp
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name mpc-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "mpc-*") mpc
            case $(uname -m) in
                x86_64)
                    sed -e '/m64=/s/lib64/lib/' \
                        -i.orig gcc/config/i386/t-linux64
                ;;
            esac
            echo "---确认---"
            diff gcc/config/i386/t-linux64.orig gcc/config/i386/t-linux64
            echo "------"
            sleep 5
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            ../configure                  \
                --target=$LFS_TGT         \
                --prefix=$LFS/tools       \
                --with-glibc-version=2.36 \
                --with-sysroot=$LFS       \
                --with-newlib             \
                --without-headers         \
                --disable-nls             \
                --disable-shared          \
                --disable-multilib        \
                --disable-decimal-float   \
                --disable-threads         \
                --disable-libatomic       \
                --disable-libgomp         \
                --disable-libquadmath     \
                --disable-libssp          \
                --disable-libvtv          \
                --disable-libstdcxx       \
                --enable-languages=c,c++
            make -j$LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                pushd ..
                    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
                        `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
                    echo "---确认---"
                    ls -lh `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
                    head -10 `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
                    echo "------"
                    sleep 5
                popd
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
