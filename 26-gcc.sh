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

    # 备份第一遍编译目录，尝试恢复第二遍编译目录
    if [[ -d $PKG_PATH && ! -d 1-`basename $PKG_PATH` ]]; then
        mv -v $PKG_PATH 1-`basename $PKG_PATH`
        if [ -d 2-`basename $PKG_PATH` ]; then
            mv -v 2-`basename $PKG_PATH` $PKG_PATH
        else
            unset PKG_PATH
        fi
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        pushd $PKG_PATH
            case $(uname -m) in
                x86_64)
                    sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
                    ;;
            esac
            mkdir build
            pushd build
                mkdir -pv $LFS_TGT/libgcc
                ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
                ../configure                                       \
                    --build=$(../config.guess)                     \
                    --host=$LFS_TGT                                \
                    --prefix=/usr                                  \
                    CC_FOR_TARGET=$LFS_TGT-gcc                     \
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
                    --disable-libstdcxx                            \
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
