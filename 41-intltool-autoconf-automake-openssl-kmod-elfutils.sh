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
    PKG_NAME=intltool
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed -i 's:\\\${:\\\$\\{:' intltool-update.in
            ./configure --prefix=/usr
            make && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=autoconf
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr
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
    PKG_NAME=automake
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr --docdir=/usr/share/doc/automake
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
    PKG_NAME=openssl
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./config --prefix=/usr    \
                --openssldir=/etc/ssl \
                --libdir=lib          \
                shared                \
                zlib-dynamic
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC test
            if [ $? = 0 ]; then
                sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
                make MANSUFFIX=ssl install
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=kmod
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr  \
                --sysconfdir=/etc      \
                --with-openssl         \
                --with-xz              \
                --with-zstd            \
                --with-zlib
            make -j_LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                for target in depmod insmod modinfo modprobe rmmod; do
                    ln -sfv ../bin/kmod /usr/sbin/$target
                done
                ln -sfv kmod /usr/bin/lsmod
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=elfutils
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr        \
                --disable-debuginfod         \
                --enable-libdebuginfod=dummy
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check
            if [ $? = 0 ]; then
                make -C libelf install
                install -vm644 config/libelf.pc /usr/lib/pkgconfig
                rm /usr/lib/libelf.a
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
