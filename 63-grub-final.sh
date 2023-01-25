#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 避免chroot后执行
id lfs >/dev/null 2>&1
if [ $? = 0 ]; then
    source `dirname ${BASH_SOURCE[0]}`/lfs.sh

    # 下载 UEFI Boot for GRUB 的依赖源码
    pushd $LFS/sources/$(getConf LFS_VERSION)
        # 依赖1: https://linuxfromscratch.org/blfs/view/stable-systemd/postlfs/efivar.html
        PKG_NAME=efivar
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://github.com/rhboot/efivar/releases/download/38/efivar-38.tar.bz2
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # efivar 依赖: https://linuxfromscratch.org/blfs/view/stable-systemd/general/mandoc.html
        PKG_NAME=mandoc
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://mandoc.bsd.lv/snapshots/mandoc-1.14.6.tar.gz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # 依赖2：https://linuxfromscratch.org/blfs/view/stable-systemd/postlfs/efibootmgr.html
        PKG_NAME=efibootmgr
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://github.com/rhboot/efibootmgr/archive/18/efibootmgr-18.tar.gz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # efibootmgr 依赖: https://linuxfromscratch.org/blfs/view/stable-systemd/general/popt.html
        PKG_NAME=popt
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget http://ftp.rpm.org/popt/releases/popt-1.x/popt-1.18.tar.gz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # grub 依赖：https://linuxfromscratch.org/blfs/view/stable-systemd/postlfs/grub-efi.html
        PKG_NAME=unifont
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://unifoundry.com/pub/unifont/unifont-14.0.04/font-builds/unifont-14.0.04.pcf.gz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

    popd

    # 准备chroot
    cp -v ${BASH_SOURCE[0]} $LFS/task.sh
    sed "s/_LFS_VERSION/$(getConf LFS_VERSION)/g" -i $LFS/task.sh
    sed "s/_LFS_BUILD_PROC/$LFS_BUILD_PROC/g" -i $LFS/task.sh
    source `dirname ${BASH_SOURCE[0]}`/chroot.sh
    rm -fv $LFS/task.sh
    exit
fi

# 来自chroot之后的调用

# GRUB 引导，需要借助BLFS：https://linuxfromscratch.org/blfs/view/stable-systemd/
# 详见 Packages for UEFI Boot

pushd /sources/_LFS_VERSION
    PKG_NAME=mandoc
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure
            [ $? = 0 ] && make mandoc
            [ $? = 0 ] && make regress && read -p "$PKG_NAME CHECK DONE..."
            if [ $? = 0 ]; then
                install -vm755 mandoc   /usr/bin &&
                install -vm644 mandoc.1 /usr/share/man/man1

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
    PKG_NAME=efivar
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            # First, fix an issue in Makefile causing the package to be rebuilt during installation
            sed '/prep :/a\\ttouch prep' -i src/Makefile
            # Now adapt this package for a change in glibc-2.36
            sed '/sys\/mount\.h/d' -i src/util.h
            sed '/unistd\.h/a#include <sys/mount.h>' -i src/gpt.c src/linux.c

            [ $? = 0 ] && make
            [ $? = 0 ] && make install LIBDIR=/usr/lib
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
    PKG_NAME=popt
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr --disable-static

            [ $? = 0 ] && make
            [ $? = 0 ] && make check && read -p "$PKG_NAME CHECK DONE..."
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
    PKG_NAME=efibootmgr
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            [ $? = 0 ] && make EFIDIR=LFS EFI_LOADER=grubx64.efi
            [ $? = 0 ] && make install EFIDIR=LFS
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
    PKG_NAME=grub
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            mkdir -pv /usr/share/fonts/unifont &&
            gunzip -c /sources/_LFS_VERSION/unifont-14.0.04.pcf.gz > /usr/share/fonts/unifont/unifont.pcf

            unset {C,CPP,CXX,LD}FLAGS

            ./configure --prefix=/usr        \
                --sysconfdir=/etc    \
                --disable-efiemu     \
                --enable-grub-mkfont \
                --with-platform=efi  \
                --target=x86_64      \
                --disable-werror     &&
            unset TARGET_CC &&
            make

            [ $? = 0 ] && make install
            if [ $? = 0 ]; then
                mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
                read -p "$PKG_NAME ALL DONE..."
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd


# GRUB 安装与配置
grub-install
grub-mkconfig -o /boot/grub/grub.cfg

# 系统发布信息
echo 11.2-systemd > /etc/lfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="11.2-systemd"
DISTRIB_CODENAME="loaden"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="11.2-systemd"
ID=lfs
PRETTY_NAME="Linux From Scratch 11.2-systemd"
VERSION_CODENAME="loaden"
EOF