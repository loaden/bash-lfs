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
    PKG_NAME=binutils
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

    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage2
        PKG_PATH=$(find stage2 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            find ../.. -maxdepth 1 -type f -name "$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
            [ $? != 0 ] && exit 1
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        pushd $PKG_PATH
            [ -f ltmain.sh.bak ] || cp ltmain.sh ltmain.sh.bak
            sed '6009s/$add_dir//' -i ltmain.sh
            echo "---确认---"
            diff ltmain.sh.bak ltmain.sh
            echo "------"
            sleep 5
            mkdir build
            pushd build
                ../configure                   \
                    --prefix=/usr              \
                    --build=$(../config.guess) \
                    --host=$LFS_TGT            \
                    --disable-nls              \
                    --enable-shared            \
                    --enable-gprofng=no        \
                    --disable-werror           \
                    --enable-64-bit-bfd
                make -j$LFS_BUILD_PROC && make DESTDIR=$LFS install
                if [ $? = 0 ]; then
                    # 移除对交叉编译有害的 libtool 档案文件，同时移除不必要的静态库
                    rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
                    touch _BUILD_DONE
                else
                    exit 1
                fi
            popd
        popd
    fi
popd
