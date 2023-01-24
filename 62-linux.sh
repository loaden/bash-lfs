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
    PKG_NAME=linux
    PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage5
        PKG_PATH=$(find stage5 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            # 确保内核源代码树绝对干净
            make mrproper

            # 生成默认配置
            make defconfig
            mv .config .config.def

            # 根据当前模块使用情况生成内核配置
            make localmodconfig
            mv .config .config.mod

            # 合并配置
            scripts/kconfig/merge_config.sh -y .config.def .config.mod
            cp .config .config.merge

            # 合并前后对比
            echo "合并前后对比->"
            scripts/diffconfig .config.mod .config.merge
            read -p "<-合并前后对比"

            #
            # 必要的配置调整
            #

            # [ ] Compile the kernel with warnings as errors [CONFIG_WERROR]
            scripts/config -d CONFIG_WERROR

            # [ ] Auditing Support [CONFIG_AUDIT]
            scripts/config -d CONFIG_AUDIT

            # < > Enable kernel headers through /sys/kernel/kheaders.tar.xz [CONFIG_IKHEADERS]
            scripts/config -d CONFIG_IKHEADERS

            # [*] Control Group support [CONFIG_CGROUPS]
            #   [*] Memory controller [CONFIG_MEMCG]
            scripts/config -e CONFIG_CGROUPS
            scripts/config -e CONFIG_MEMCG

            # [ ] Enable deprecated sysfs features to support old userspace tools [CONFIG_SYSFS_DEPRECATED]
            scripts/config -d CONFIG_SYSFS_DEPRECATED

            # [*] Configure standard kernel features (expert users) [CONFIG_EXPERT] --->
            #   [*] open by fhandle syscalls [CONFIG_FHANDLE]
            scripts/config -e CONFIG_EXPERT
            scripts/config -e CONFIG_FHANDLE

            # [*] Pressure stall information tracking [CONFIG_PSI]
            scripts/config -e CONFIG_PSI

            # [*] Enable seccomp to safely compute untrusted bytecode [CONFIG_SECCOMP]
            scripts/config -e CONFIG_SECCOMP

            # <*> The IPv6 protocol [CONFIG_IPV6]
            scripts/config -e CONFIG_IPV6

            # [*] Export DMI identification via sysfs to userspace [CONFIG_DMIID]
            scripts/config -e CONFIG_DMIID

            # [*] Support for frame buffer devices
            scripts/config -e CONFIG_FB

            # [ ] Support for uevent helper [CONFIG_UEVENT_HELPER]
            scripts/config -d CONFIG_UEVENT_HELPER

            # [*] Maintain a devtmpfs filesystem to mount at /dev [CONFIG_DEVTMPFS]
            #   [*] Automount devtmpfs at /dev, after the kernel mounted the rootfs [CONFIG_DEVTMPFS_MOUNT]
            scripts/config -e CONFIG_DEVTMPFS
            scripts/config -e CONFIG_DEVTMPFS_MOUNT

            # [ ] Enable the firmware sysfs fallback mechanism [CONFIG_FW_LOADER_USER_HELPER]
            scripts/config -d CONFIG_FW_LOADER_USER_HELPER

            # [*] Inotify support for userspace [CONFIG_INOTIFY_USER]
            scripts/config -e CONFIG_INOTIFY_USER

            # [*] Tmpfs POSIX Access Control Lists [CONFIG_TMPFS_POSIX_ACL]
            scripts/config -e CONFIG_TMPFS_POSIX_ACL

            # [*] PCI Support ---> [CONFIG_PCI]
            #   [*] Message Signaled Interrupts (MSI and MSI-X) [CONFIG_PCI_MSI]
            scripts/config -e CONFIG_PCI
            scripts/config -e CONFIG_PCI_MSI

            # [*] IOMMU Hardware Support ---> [CONFIG_IOMMU_SUPPORT]
            #   [*] Support for Interrupt Remapping [CONFIG_IRQ_REMAP]
            scripts/config -e CONFIG_IOMMU_SUPPORT
            scripts/config -e CONFIG_IRQ_REMAP

            # [*] Support x2apic [CONFIG_X86_X2APIC]
            scripts/config -e CONFIG_X86_X2APIC

            # [ ] Enable userfaultfd() system call [CONFIG_USERFAULTFD]
            scripts/config -d CONFIG_USERFAULTFD

            # 刷新
            scripts/config  --refresh

            # 备份
            cp .config .config.opti

            # 优化前后对比
            echo "优化前后对比->"
            scripts/diffconfig .config.merge .config.opti
            read -p "<-优化前后对比"

            # 图形界面调整配置，配置后记得保存
            make menuconfig

            # 优化前后对比
            echo "图形界面调整对比->"
            scripts/diffconfig .config.opti .config
            read -p "<-图形界面调整对比"

            # 查看配置文件
            ls -lh .config*

            if [ $? = 0 ]; then
                read -p "$PKG_NAME ALL DONE..."
                # touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
