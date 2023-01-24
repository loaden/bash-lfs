#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 避免chroot后执行
id lfs >/dev/null 2>&1
if [ $? = 0 ]; then
    source `dirname ${BASH_SOURCE[0]}`/lfs.sh
    cp -v ${BASH_SOURCE[0]} $LFS/task.sh
    sed "s/_LFS_VERSION/$(getConf LFS_VERSION)/g" -i $LFS/task.sh
    sed "s/_LFS_BUILD_PROC/$LFS_BUILD_PROC/g" -i $LFS/task.sh
    source `dirname ${BASH_SOURCE[0]}`/chroot.sh
    rm -fv $LFS/task.sh
    exit
fi

# 来自chroot之后的调用
pushd /sources/_LFS_VERSION
    PKG_NAME=util-linux
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
                --bindir=/usr/bin    \
                --libdir=/usr/lib    \
                --sbindir=/usr/sbin  \
                --docdir=/usr/share/doc/util-linux-2.38.1 \
                --disable-chfn-chsh  \
                --disable-login      \
                --disable-nologin    \
                --disable-su         \
                --disable-setpriv    \
                --disable-runuser    \
                --disable-pylibmount \
                --disable-static     \
                --without-python

            [ $? = 0 ] && make -j_LFS_BUILD_PROC

            if [ $? = 0 ]; then
                chown -Rv tester .
                su tester -c "make -k check"
                read -p "$PKG_NAME CHECK DONE..."
            fi

            [ $? = 0 ] && make install
            if [ $? = 0 ]; then
                read -p "$PKG_NAME ALL DONE..."
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=e2fsprogs
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            ../configure --prefix=/usr  \
                --sysconfdir=/etc       \
                --enable-elf-shlibs     \
                --disable-libblkid      \
                --disable-libuuid       \
                --disable-uuidd         \
                --disable-fsck

            [ $? = 0 ] && make -j_LFS_BUILD_PROC
            if [ $? = 0 ]; then
                # 已知一项名为 u_direct_io 的测试可能在一些系统上失败
                # 370 tests succeeded     1 tests failed
                make -j_LFS_BUILD_PROC -k check
                read -p "$PKG_NAME CHECK DONE..."
            fi

            [ $? = 0 ] && make install
            if [ $? = 0 ]; then
                # 删除无用的静态库
                rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
                # 解压并更新系统 dir 文件
                gunzip -v /usr/share/info/libext2fs.info.gz
                install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
                # 创建并安装一些额外的文档
                makeinfo -o      doc/com_err.info ../lib/et/com_err.texinfo
                install -v -m644 doc/com_err.info /usr/share/info
                install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

                read -p "$PKG_NAME ALL DONE..."
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
