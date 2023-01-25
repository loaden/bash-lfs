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


# initramfs 生成脚本
cat > /usr/sbin/mkinitramfs << "EOF"
#!/bin/bash
# This file based in part on the mkinitramfs script for the LFS LiveCD
# written by Alexander E. Patrakov and Jeremy Huntwork.

copy()
{
  local file

  if [ "$2" = "lib" ]; then
    file=$(PATH=/usr/lib type -p $1)
  else
    file=$(type -p $1)
  fi

  if [ -n "$file" ] ; then
    cp $file $WDIR/usr/$2
  else
    echo "Missing required file: $1 for directory $2"
    rm -rf $WDIR
    exit 1
  fi
}

if [ -z $1 ] ; then
  INITRAMFS_FILE=initrd.img-no-kmods
else
  KERNEL_VERSION=$1
  INITRAMFS_FILE=initrd.img-$KERNEL_VERSION
fi

if [ -n "$KERNEL_VERSION" ] && [ ! -d "/usr/lib/modules/$1" ] ; then
  echo "No modules directory named $1"
  exit 1
fi

printf "Creating $INITRAMFS_FILE... "

binfiles="sh cat cp dd killall ls mkdir mknod mount "
binfiles="$binfiles umount sed sleep ln rm uname"
binfiles="$binfiles readlink basename"

# Systemd installs udevadm in /bin. Other udev implementations have it in /sbin
if [ -x /usr/bin/udevadm ] ; then binfiles="$binfiles udevadm"; fi

sbinfiles="modprobe blkid switch_root"

# Optional files and locations
for f in mdadm mdmon udevd udevadm; do
  if [ -x /usr/sbin/$f ] ; then sbinfiles="$sbinfiles $f"; fi
done

# Add lvm if present (cannot be done with the others because it
# also needs dmsetup
if [ -x /usr/sbin/lvm ] ; then sbinfiles="$sbinfiles lvm dmsetup"; fi

unsorted=$(mktemp /tmp/unsorted.XXXXXXXXXX)

DATADIR=/usr/share/mkinitramfs
INITIN=init.in

# Create a temporary working directory
WDIR=$(mktemp -d /tmp/initrd-work.XXXXXXXXXX)

# Create base directory structure
mkdir -p $WDIR/{dev,run,sys,proc,usr/{bin,lib/{firmware,modules},sbin}}
mkdir -p $WDIR/etc/{modprobe.d,udev/rules.d}
touch $WDIR/etc/modprobe.d/modprobe.conf
ln -s usr/bin  $WDIR/bin
ln -s usr/lib  $WDIR/lib
ln -s usr/sbin $WDIR/sbin
ln -s lib      $WDIR/lib64

# Create necessary device nodes
mknod -m 640 $WDIR/dev/console c 5 1
mknod -m 664 $WDIR/dev/null    c 1 3

# Install the udev configuration files
if [ -f /etc/udev/udev.conf ]; then
  cp /etc/udev/udev.conf $WDIR/etc/udev/udev.conf
fi

for file in $(find /etc/udev/rules.d/ -type f) ; do
  cp $file $WDIR/etc/udev/rules.d
done

# Install any firmware present
cp -a /usr/lib/firmware $WDIR/usr/lib

# Copy the RAID configuration file if present
if [ -f /etc/mdadm.conf ] ; then
  cp /etc/mdadm.conf $WDIR/etc
fi

# Install the init file
install -m0755 $DATADIR/$INITIN $WDIR/init

if [  -n "$KERNEL_VERSION" ] ; then
  if [ -x /usr/bin/kmod ] ; then
    binfiles="$binfiles kmod"
  else
    binfiles="$binfiles lsmod"
    sbinfiles="$sbinfiles insmod"
  fi
fi

# Install basic binaries
for f in $binfiles ; do
  ldd /usr/bin/$f | sed "s/\t//" | cut -d " " -f1 >> $unsorted
  copy /usr/bin/$f bin
done

for f in $sbinfiles ; do
  ldd /usr/sbin/$f | sed "s/\t//" | cut -d " " -f1 >> $unsorted
  copy $f sbin
done

# Add udevd libraries if not in /usr/sbin
if [ -x /usr/lib/udev/udevd ] ; then
  ldd /usr/lib/udev/udevd | sed "s/\t//" | cut -d " " -f1 >> $unsorted
elif [ -x /usr/lib/systemd/systemd-udevd ] ; then
  ldd /usr/lib/systemd/systemd-udevd | sed "s/\t//" | cut -d " " -f1 >> $unsorted
fi

# Add module symlinks if appropriate
if [ -n "$KERNEL_VERSION" ] && [ -x /usr/bin/kmod ] ; then
  ln -s kmod $WDIR/usr/bin/lsmod
  ln -s kmod $WDIR/usr/bin/insmod
fi

# Add lvm symlinks if appropriate
# Also copy the lvm.conf file
if  [ -x /usr/sbin/lvm ] ; then
  ln -s lvm $WDIR/usr/sbin/lvchange
  ln -s lvm $WDIR/usr/sbin/lvrename
  ln -s lvm $WDIR/usr/sbin/lvextend
  ln -s lvm $WDIR/usr/sbin/lvcreate
  ln -s lvm $WDIR/usr/sbin/lvdisplay
  ln -s lvm $WDIR/usr/sbin/lvscan

  ln -s lvm $WDIR/usr/sbin/pvchange
  ln -s lvm $WDIR/usr/sbin/pvck
  ln -s lvm $WDIR/usr/sbin/pvcreate
  ln -s lvm $WDIR/usr/sbin/pvdisplay
  ln -s lvm $WDIR/usr/sbin/pvscan

  ln -s lvm $WDIR/usr/sbin/vgchange
  ln -s lvm $WDIR/usr/sbin/vgcreate
  ln -s lvm $WDIR/usr/sbin/vgscan
  ln -s lvm $WDIR/usr/sbin/vgrename
  ln -s lvm $WDIR/usr/sbin/vgck
  # Conf file(s)
  cp -a /etc/lvm $WDIR/etc
fi

# Install libraries
sort $unsorted | uniq | while read library ; do
# linux-vdso and linux-gate are pseudo libraries and do not correspond to a file
# libsystemd-shared is in /lib/systemd, so it is not found by copy, and
# it is copied below anyway
  if [[ "$library" == linux-vdso.so.1 ]] ||
     [[ "$library" == linux-gate.so.1 ]] ||
     [[ "$library" == libsystemd-shared* ]]; then
    continue
  fi

  copy $library lib
done

if [ -d /usr/lib/udev ]; then
  cp -a /usr/lib/udev $WDIR/usr/lib
fi
if [ -d /usr/lib/systemd ]; then
  cp -a /usr/lib/systemd $WDIR/usr/lib
fi
if [ -d /usr/lib/elogind ]; then
  cp -a /usr/lib/elogind $WDIR/usr/lib
fi

# Install the kernel modules if requested
if [ -n "$KERNEL_VERSION" ]; then
  find \
     /usr/lib/modules/$KERNEL_VERSION/kernel/{crypto,fs,lib}                      \
     /usr/lib/modules/$KERNEL_VERSION/kernel/drivers/{block,ata,nvme,md,firewire} \
     /usr/lib/modules/$KERNEL_VERSION/kernel/drivers/{scsi,message,pcmcia,virtio} \
     /usr/lib/modules/$KERNEL_VERSION/kernel/drivers/usb/{host,storage}           \
     -type f 2> /dev/null | cpio --make-directories -p --quiet $WDIR

  cp /usr/lib/modules/$KERNEL_VERSION/modules.{builtin,order} \
            $WDIR/usr/lib/modules/$KERNEL_VERSION
  if [ -f /usr/lib/modules/$KERNEL_VERSION/modules.builtin.modinfo ]; then
    cp /usr/lib/modules/$KERNEL_VERSION/modules.builtin.modinfo \
            $WDIR/usr/lib/modules/$KERNEL_VERSION
  fi

  depmod -b $WDIR $KERNEL_VERSION
fi

( cd $WDIR ; find . | cpio -o -H newc --quiet | gzip -9 ) > $INITRAMFS_FILE

# Prepare early loading of microcode if available
if ls /usr/lib/firmware/intel-ucode/* >/dev/null 2>&1 ||
   ls /usr/lib/firmware/amd-ucode/*   >/dev/null 2>&1; then

# first empty WDIR to reuse it
  rm -r $WDIR/*

  DSTDIR=$WDIR/kernel/x86/microcode
  mkdir -p $DSTDIR

  if [ -d /usr/lib/firmware/amd-ucode ]; then
    cat /usr/lib/firmware/amd-ucode/microcode_amd*.bin > $DSTDIR/AuthenticAMD.bin
  fi

  if [ -d /usr/lib/firmware/intel-ucode ]; then
    cat /usr/lib/firmware/intel-ucode/* > $DSTDIR/GenuineIntel.bin
  fi

  ( cd $WDIR; find . | cpio -o -H newc --quiet ) > microcode.img
  cat microcode.img $INITRAMFS_FILE > tmpfile
  mv tmpfile $INITRAMFS_FILE
  rm microcode.img
fi

# Remove the temporary directories and files
rm -rf $WDIR $unsorted
printf "done.\n"

EOF

chmod 0755 /usr/sbin/mkinitramfs

mkdir -p /usr/share/mkinitramfs &&
cat > /usr/share/mkinitramfs/init.in << "EOF"
#!/bin/sh

PATH=/usr/bin:/usr/sbin
export PATH

problem()
{
   printf "Encountered a problem!\n\nDropping you to a shell.\n\n"
   sh
}

no_device()
{
   printf "The device %s, which is supposed to contain the\n" $1
   printf "root file system, does not exist.\n"
   printf "Please fix this problem and exit this shell.\n\n"
}

no_mount()
{
   printf "Could not mount device %s\n" $1
   printf "Sleeping forever. Please reboot and fix the kernel command line.\n\n"
   printf "Maybe the device is formatted with an unsupported file system?\n\n"
   printf "Or maybe filesystem type autodetection went wrong, in which case\n"
   printf "you should add the rootfstype=... parameter to the kernel command line.\n\n"
   printf "Available partitions:\n"
}

do_mount_root()
{
   mkdir /.root
   [ -n "$rootflags" ] && rootflags="$rootflags,"
   rootflags="$rootflags$ro"

   case "$root" in
      /dev/*    ) device=$root ;;
      UUID=*    ) eval $root; device="/dev/disk/by-uuid/$UUID" ;;
      PARTUUID=*) eval $root; device="/dev/disk/by-partuuid/$PARTUUID" ;;
      LABEL=*   ) eval $root; device="/dev/disk/by-label/$LABEL" ;;
      ""        ) echo "No root device specified." ; problem ;;
   esac

   while [ ! -b "$device" ] ; do
       no_device $device
       problem
   done

   if ! mount -n -t "$rootfstype" -o "$rootflags" "$device" /.root ; then
       no_mount $device
       cat /proc/partitions
       while true ; do sleep 10000 ; done
   else
       echo "Successfully mounted device $root"
   fi
}

do_try_resume()
{
   case "$resume" in
      UUID=* ) eval $resume; resume="/dev/disk/by-uuid/$UUID"  ;;
      LABEL=*) eval $resume; resume="/dev/disk/by-label/$LABEL" ;;
   esac

   if $noresume || ! [ -b "$resume" ]; then return; fi

   ls -lH "$resume" | ( read x x x x maj min x
       echo -n ${maj%,}:$min > /sys/power/resume )
}

init=/sbin/init
root=
rootdelay=
rootfstype=auto
ro="ro"
rootflags=
device=
resume=
noresume=false

mount -n -t devtmpfs devtmpfs /dev
mount -n -t proc     proc     /proc
mount -n -t sysfs    sysfs    /sys
mount -n -t tmpfs    tmpfs    /run

read -r cmdline < /proc/cmdline

for param in $cmdline ; do
  case $param in
    init=*      ) init=${param#init=}             ;;
    root=*      ) root=${param#root=}             ;;
    rootdelay=* ) rootdelay=${param#rootdelay=}   ;;
    rootfstype=*) rootfstype=${param#rootfstype=} ;;
    rootflags=* ) rootflags=${param#rootflags=}   ;;
    resume=*    ) resume=${param#resume=}         ;;
    noresume    ) noresume=true                   ;;
    ro          ) ro="ro"                         ;;
    rw          ) ro="rw"                         ;;
  esac
done

# udevd location depends on version
if [ -x /sbin/udevd ]; then
  UDEVD=/sbin/udevd
elif [ -x /lib/udev/udevd ]; then
  UDEVD=/lib/udev/udevd
elif [ -x /lib/systemd/systemd-udevd ]; then
  UDEVD=/lib/systemd/systemd-udevd
else
  echo "Cannot find udevd nor systemd-udevd"
  problem
fi

${UDEVD} --daemon --resolve-names=never
udevadm trigger
udevadm settle

if [ -f /etc/mdadm.conf ] ; then mdadm -As                       ; fi
if [ -x /sbin/vgchange  ] ; then /sbin/vgchange -a y > /dev/null ; fi
if [ -n "$rootdelay"    ] ; then sleep "$rootdelay"              ; fi

do_try_resume # This function will not return if resuming from disk
do_mount_root

killall -w ${UDEVD##*/}

exec switch_root /.root "$init" "$@"

EOF


# 生成 initramfs
mkinitramfs 5.19.2
mv initrd.img-* /boot/initramfs.img
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
