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
    PKG_PATH=$(find stage2 -maxdepth 1 -type d -name "$PKG_NAME-*")

    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage2
        PKG_PATH=$(find stage2 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name mpfr-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "mpfr-*") mpfr
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name gmp-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "gmp-*") gmp
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name mpc-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "mpc-*") mpc
            case $(uname -m) in
                x86_64)
                    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
                ;;
            esac
            echo "---确认---"
            diff gcc/config/i386/t-linux64.orig gcc/config/i386/t-linux64
            echo "------"
            sleep 5
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed '/thread_header =/s/@.*@/gthr-posix.h/' \
                -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
            mkdir build
            pushd build
                ../configure                                       \
                    --build=$(../config.guess)                     \
                    --host=$LFS_TGT                                \
                    --target=$LFS_TGT                              \
                    LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
                    --prefix=/usr                                  \
                    --with-build-sysroot=$LFS                      \
                    --enable-initfini-array                        \
                    --disable-nls                                  \
                    --disable-multilib                             \
                    --disable-decimal-float                        \
                    --disable-libatomic                            \
                    --disable-libgomp                              \
                    --disable-libquadmath                          \
                    --disable-libssp                               \
                    --disable-libvtv                               \
                    --enable-languages=c,c++
                make -j$LFS_BUILD_PROC && make DESTDIR=$LFS install
                if [ $? = 0 ]; then
                    ln -sv gcc $LFS/usr/bin/cc
                    touch _BUILD_DONE
                else
                    exit 1
                fi
            popd
        popd
    fi
popd
