#!/bin/bash
# QQ群：111601117、钉钉群：35948877

if [ ! -f $LFS/task.sh ]; then
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
    PKG_NAME=dbus
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr                \
                --sysconfdir=/etc                    \
                --localstatedir=/var                 \
                --disable-static                     \
                --disable-doxygen-docs               \
                --disable-xml-docs                   \
                --docdir=/usr/share/doc/dbus-1.12.20 \
                --with-console-auth-dir=/run/console \
                --with-system-pid-file=/run/dbus/pid \
                --with-system-socket=/run/dbus/system_bus_socket
            make -j_LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                ln -sfv /etc/machine-id /var/lib/dbus
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=man-db
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr                 \
                --docdir=/usr/share/doc/man-db-2.10.1 \
                --sysconfdir=/etc                     \
                --disable-setuid                      \
                --enable-cache-owner=bin              \
                --with-browser=/usr/bin/lynx          \
                --with-vgrind=/usr/bin/vgrind         \
                --with-grap=/usr/bin/grap
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=procps
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr               \
                --docdir=/usr/share/doc/procps-ng   \
                --disable-static                    \
                --disable-kill                      \
                --with-systemd
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                pwd
                read -p "FIXME: procps 测试失败，任意键继续..."
                make install || exit 1
                touch _BUILD_DONE
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=util-linux
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
                --bindir=/usr/bin    \
                --libdir=/usr/lib    \
                --sbindir=/usr/sbin  \
                --docdir=/usr/share/doc/util-linux-2.37.4 \
                --disable-chfn-chsh  \
                --disable-login      \
                --disable-nologin    \
                --disable-su         \
                --disable-setpriv    \
                --disable-runuser    \
                --disable-pylibmount \
                --disable-static     \
                --without-python
            make -j_LFS_BUILD_PROC || exit 99
            # FIXME: util-linux 测试会死锁
            # chown -Rv tester .
            # su tester -c "make TESTSUITEFLAGS=-j_LFS_BUILD_PROC -k check"
            if [ $? = 0 ]; then
                make install
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=e2fsprogs
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
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
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
                gunzip -v /usr/share/info/libext2fs.info.gz
                install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
                touch _BUILD_DONE
            else
                pwd
                read -p "FIXME: e2fsprogs 测试失败，任意键继续..."
                make install || exit 1
                rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
                gunzip -v /usr/share/info/libext2fs.info.gz
                install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
                touch _BUILD_DONE
            fi
        popd
    fi
popd
