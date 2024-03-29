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
            # make mrproper

            # 删除默认配置
            rm -fv .config

            # 生成默认配置
            make ARCH=x86_64 defconfig
            mv -fv .config .config.def

            # 根据当前模块使用情况生成内核配置
            make ARCH=x86_64 localmodconfig
            mv -fv .config .config.mod

            # 合并配置
            scripts/kconfig/merge_config.sh -y .config.def .config.mod
            cp -fv .config .config.merge

            # 合并前后对比
            echo "合并前后对比->"
            scripts/diffconfig .config.mod .config.merge
            read -p "<-合并前后对比"

            #
            # 推荐配置调整
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
            cp -fv .config .config.lfs

            # 推荐配置调整前后对比
            echo "推荐配置调整前后对比->"
            scripts/diffconfig .config.merge .config.lfs
            read -p "<-推荐配置调整前后对比"

            #
            # 扩展配置与优化
            #

            # ((none)) Default hostname [CONFIG_DEFAULT_HOSTNAME]
            scripts/config --set-str CONFIG_DEFAULT_HOSTNAME "(none)"

            # ()  Local version - append to kernel release [CONFIG_LOCALVERSION]
            scripts/config --set-str CONFIG_LOCALVERSION ""

            # 支持2.4G无线键盘
            # <*> USB HID transport layer
            scripts/config -e CONFIG_USB_HID

            # 提高桌面响应速度
            # (X) Preemptible Kernel (Low-Latency Desktop) [CONFIG_PREEMPT]
            scripts/config -e CONFIG_PREEMPT
            # (X) Idle dynticks system (tickless idle) [CONFIG_NO_HZ_IDLE]
            scripts/config -e CONFIG_NO_HZ_IDLE
            # (X) Simple tick based cputime accounting [CONFIG_TICK_CPU_ACCOUNTING]
            scripts/config -e CONFIG_TICK_CPU_ACCOUNTING

            # 桌面系统的“鸡血补丁”，开启后能显著降低操作延迟、提升程序响应速度
            # [*] Automatic process group schedulin [CONFIG_SCHED_AUTOGROUP]
            scripts/config -e CONFIG_SCHED_AUTOGROUP

            # 内存压缩
            # <M> Compressed RAM block device support [CONFIG_ZRAM]
            #   Default zram compressor (zstd)  ---> [CONFIG_ZRAM_DEF_COMP_ZSTD]
            scripts/config -m CONFIG_ZRAM
            scripts/config -e CONFIG_ZRAM_DEF_COMP_ZSTD

            # 内核模块不压缩
            #  Module compression mode (None)  ---> [CONFIG_MODULE_COMPRESS_NONE]
            scripts/config -e CONFIG_MODULE_COMPRESS_NONE
            scripts/config -d MODULE_COMPRESS_ZSTD

            # 文件系统
            # <*> Btrfs filesystem support [BTRFS_FS]
            scripts/config -e BTRFS_FS
            # <M> The Extended 4 (ext4) filesystem [CONFIG_EXT4_FS]
            scripts/config -m CONFIG_EXT4_FS
            # <M> exFAT filesystem support [CONFIG_EXFAT_FS]
            scripts/config -m CONFIG_EXFAT_FS
            # <M> NTFS file system support [CONFIG_NTFS_FS]
            #   [*]   NTFS write support [CONFIG_NTFS_RW]
            scripts/config -m CONFIG_NTFS_FS
            scripts/config -e CONFIG_NTFS_RW
            # <M> NTFS Read-Write file system support [CONFIG_NTFS3_FS]
            scripts/config -m CONFIG_NTFS3_FS

            # iwd无线网络（同时支持有线网络、DHCP）：https://wiki.gentoo.org/wiki/Iwd
            # [*]   Diffie-Hellman operations on retained keys [CONFIG_KEY_DH_OPERATIONS]
            scripts/config -e CONFIG_KEY_DH_OPERATIONS
            # <*>   cfg80211 - wireless configuration API [CONFIG_CFG80211]
            scripts/config -e CONFIG_CFG80211
            # *** Block modes ***
            # {*}   ECB support [CONFIG_CRYPTO_ECB]
            scripts/config -e CONFIG_CRYPTO_ECB
            # *** Digest ***
            # <*>   MD4 digest algorithm [CONFIG_CRYPTO_MD4]
            scripts/config -e CONFIG_CRYPTO_MD4
            # <*>   SHA1 digest algorithm (SSSE3/AVX/AVX2/SHA-NI) [CONFIG_CRYPTO_SHA1_SSSE3]
            scripts/config -e CONFIG_CRYPTO_SHA1_SSSE3
            # <*>   SHA256 digest algorithm (SSSE3/AVX/AVX2/SHA-NI) [CONFIG_CRYPTO_SHA256_SSSE3]
            scripts/config -e CONFIG_CRYPTO_SHA256_SSSE3
            # <*>   SHA512 digest algorithm (SSSE3/AVX/AVX2) [CONFIG_CRYPTO_SHA512_SSSE3]
            scripts/config -e CONFIG_CRYPTO_SHA512_SSSE3
            # *** Ciphers ***
            # <*>   AES cipher algorithms (AES-NI) [CONFIG_CRYPTO_AES_NI_INTEL]
            scripts/config -e CONFIG_CRYPTO_AES_NI_INTEL
            # <*>   DES and Triple DES EDE cipher algorithms [CONFIG_CRYPTO_DES]
            scripts/config -e CONFIG_CRYPTO_DES
            # <*>   Triple DES EDE cipher algorithm (x86-64) [CONFIG_CRYPTO_DES3_EDE_X86_64]
            scripts/config -e CONFIG_CRYPTO_DES3_EDE_X86_64
            # *** Random Number Generation ***
            # <*>   User-space interface for hash algorithms [CONFIG_CRYPTO_USER_API_HASH]
            scripts/config -e CONFIG_CRYPTO_USER_API_HASH
            # <*>   User-space interface for symmetric key cipher algorithms [CONFIG_CRYPTO_USER_API_SKCIPHER]
            scripts/config -e CONFIG_CRYPTO_USER_API_SKCIPHER
            # <*>   PKCS#8 private key parser [CONFIG_PKCS8_PRIVATE_KEY_PARSER]
            scripts/config -e CONFIG_PKCS8_PRIVATE_KEY_PARSER

            # Intel 无线网卡
            # Device Drivers > Network device support > Wireless LAN
            # [*]   Intel devices [CONFIG_WLAN_VENDOR_INTEL]
            scripts/config -e CONFIG_WLAN_VENDOR_INTEL
            # <*>     Intel Wireless WiFi Next Gen AGN - Wireless-N/Advanced-N/Ultimate-N (iwlwifi) [CONFIG_IWLWIFI]
            scripts/config -e CONFIG_IWLWIFI
            # <M>       Intel Wireless WiFi MVM Firmware support [CONFIG_IWLMVM]
            scripts/config -m CONFIG_IWLMVM

            # 刷新
            scripts/config  --refresh

            # 备份
            cp -vf .config .config.opti

            # 扩展配置与优化前后对比
            echo "扩展配置与优化前后对比->"
            scripts/diffconfig .config.lfs .config.opti
            read -p "<-扩展配置与优化前后对比"

            # 图形界面调整配置，配置后记得保存
            make ARCH=x86_64 menuconfig

            # 手动调整对比
            echo "手动调整对比->"
            scripts/diffconfig .config.opti .config
            read -p "<-手动调整对比"

            # 查看配置文件
            ls -lh .config*

            [ $? = 0 ] && make -j_LFS_BUILD_PROC
            [ $? = 0 ] && make modules_install
            [ $? = 0 ] && make install
            if [ $? = 0 ]; then
                # 备份配置
                cp -fv .config /boot/config-5.19.2
                # 安装文档
                install -d /usr/share/doc/linux-5.19.2
                cp -r Documentation/* /usr/share/doc/linux-5.19.2
                # 设置USB驱动加载顺序，以避免启动警告
                install -v -m755 -d /etc/modprobe.d
                cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

                read -p "$PKG_NAME ALL DONE..."
                # touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
