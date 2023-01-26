#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# 避免chroot后执行
id lfs >/dev/null 2>&1
if [ $? = 0 ]; then
    source `dirname ${BASH_SOURCE[0]}`/lfs.sh

    # 下载 UEFI Boot for GRUB 的依赖源码
    # BLFS国内镜像源 https://mirrors.aliyun.com/blfs/
    pushd $LFS/sources/$(getConf LFS_VERSION)
        # 删除缓存
        rm wget-*

        # 依赖1: https://linuxfromscratch.org/blfs/view/stable-systemd/postlfs/efivar.html
        PKG_NAME=efivar
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            # wget https://github.com/rhboot/efivar/releases/download/38/efivar-38.tar.bz2
            wget https://mirrors.aliyun.com/blfs/11.2/e/efivar-38.tar.bz2
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # efivar 依赖: https://linuxfromscratch.org/blfs/view/stable-systemd/general/mandoc.html
        PKG_NAME=mandoc
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            # wget https://mandoc.bsd.lv/snapshots/mandoc-1.14.6.tar.gz
            wget https://mirrors.aliyun.com/blfs/11.2/m/mandoc-1.14.6.tar.gz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # 依赖2：https://linuxfromscratch.org/blfs/view/stable-systemd/postlfs/efibootmgr.html
        PKG_NAME=efibootmgr
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            # wget https://github.com/rhboot/efibootmgr/archive/18/efibootmgr-18.tar.gz
            wget https://mirrors.aliyun.com/blfs/11.2/e/efibootmgr-18.tar.gz
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

        # initramfs 依赖: https://www.linuxfromscratch.org/blfs/view/svn/general/cpio.html
        PKG_NAME=cpio
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://ftp.gnu.org/gnu/cpio/cpio-2.13.tar.bz2
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # dracut 生成 initramfs：https://github.com/dracutdevs/dracut
        PKG_NAME=dracut
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://github.com/dracutdevs/dracut/archive/refs/tags/059.tar.gz
            [ -f 059.tar.gz ] && mv -vf 059.tar.gz dracut-059.tar.gz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # btrfs-progs：https://linuxfromscratch.org/blfs/view/stable-systemd/postlfs/btrfs-progs.html
        PKG_NAME=btrfs-progs
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://www.kernel.org/pub/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v5.19.tar.xz
            PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
            sleep 1
        done

        # btrfs-progs 依赖：https://linuxfromscratch.org/blfs/view/stable-systemd/general/lzo.html
        PKG_NAME=lzo
        PKG_PATH=$(find . -maxdepth 1 -type f -name "$PKG_NAME-*.*")
        while [ -z $PKG_PATH ]
        do
            wget https://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
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
            unset {C,CPP,CXX,LD}FLAGS

            ./configure --prefix=/usr        \
                --sysconfdir=/etc    \
                --disable-efiemu     \
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

pushd /sources/_LFS_VERSION
    PKG_NAME=cpio
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed -i '/The name/,+2 d' src/global.c

            ./configure --prefix=/usr \
                --enable-mt   \
                --with-rmt=/usr/libexec/rmt &&
            make &&
            makeinfo --html            -o doc/html      doc/cpio.texi &&
            makeinfo --html --no-split -o doc/cpio.html doc/cpio.texi &&
            makeinfo --plaintext       -o doc/cpio.txt  doc/cpio.texi

            [ $? = 0 ] && make check && read -p "$PKG_NAME CHECK DONE..."
            [ $? = 0 ] && make install
            if [ $? = 0 ]; then
                install -v -m755 -d /usr/share/doc/cpio-2.13/html &&
                install -v -m644    doc/html/* \
                                    /usr/share/doc/cpio-2.13/html &&
                install -v -m644    doc/cpio.{html,txt} \
                                    /usr/share/doc/cpio-2.13

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
    PKG_NAME=lzo
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr            \
                --enable-shared                  \
                --disable-static                 \
                --docdir=/usr/share/doc/lzo-2.10

            [ $? = 0 ] && make
            [ $? = 0 ] && make check && read -p "$PKG_NAME CHECK DONE..."
            [ $? = 0 ] && make test && read -p "$PKG_NAME TEST DONE..."
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
    PKG_NAME=btrfs-progs
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr --disable-documentation

            [ $? = 0 ] && make && make fssum
            if [ $? = 0 ]; then
                pushd tests
                    ./fsck-tests.sh
                    ./mkfs-tests.sh
                    ./cli-tests.sh
                    ./convert-tests.sh
                    ./misc-tests.sh
                    ./fuzz-tests.sh
                    read -p "$PKG_NAME TEST DONE..."
                popd
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
    PKG_NAME=dracut
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure             \
                --sysconfdir=/etc   \
                --sbindir=/sbin     \
                --disable-documentation

            [ $? = 0 ] && make
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

# dracut 生成 initramfs
dracut /boot/initramfs.img \
    --modules "rootfs-block base btrfs systemd kernel-modules udev-rules
               systemd-initrd systemd-modules-load systemd-udevd watchdog watchdog-modules
               kernel-modules-extra virtfs virtiofs usrmount fs-lib
               img-lib uefi-lib" \
    --force --hostonly --fstab --zstd --kver 5.19.2
ls -lh /boot

# GRUB 安装与配置

# 启动入口
# If the system is booted with UEFI and systemd, efivarfs will be mounted automatically.
# However in the LFS chroot environment it still needs to be mounted manually.
mountpoint /sys/firmware/efi/efivars || mount -v -t efivarfs efivarfs /sys/firmware/efi/efivars
grub-install --bootloader-id=LFS --recheck

# 检查生成的启动项
efibootmgr | cut -f 1

# 编写启动菜单
cat > /boot/grub/grub.cfg << EOF
# Begin /boot/grub/grub.cfg
set timeout_style=menu
set timeout=5

insmod part_gpt
insmod fat
insmod btrfs
insmod zstd
insmod efi_gop
insmod efi_uga

set root=(hd0,6)

menuentry "Linux From Scratch"  {
    linux /@lfs/boot/vmlinuz root=/dev/nvme0n1p6 rootflags=subvol=@lfs ro
    initrd /@lfs/boot/initramfs.img
}

menuentry "Firmware Setup" {
    fwsetup
}
EOF

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
