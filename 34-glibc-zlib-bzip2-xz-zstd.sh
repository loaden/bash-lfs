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
    PKG_NAME=glibc
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            find ../.. -maxdepth 1 -type f -name "$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
            [ $? != 0 ] && exit 1
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            echo "rootsbindir=/usr/sbin" > configparms
            ../configure --prefix=/usr                   \
                --disable-werror                         \
                --enable-kernel=3.2                      \
                --enable-stack-protector=strong          \
                --with-headers=/usr/include              \
                libc_cv_slibdir=/usr/lib
            make -j1
            if [ $? = 0 ]; then
                # 已知 io/tst-lchmod 在 LFS chroot 环境中会失败。
                # 已知 misc/tst-ttyname 在 LFS chroot 环境中会失败。
                # 已知 nss/tst-nss-file-hosts-long 在没有非本地回环的 IP 地址时会失败。
                # 已知 stdlib/tst-arc4random-thread 在宿主内核版本较低时会失败。
                # 一些测试，例如 nss/tst-nss-file-hosts-multi，在较慢的系统运行时会由于其内部发生超时而失败。
                make check
                read -p "$PKG_NAME CHECK DONE..."

                # 不要抱怨 /etc/ld.so.conf 不存在
                touch /etc/ld.so.conf
                # 跳过完整性检查
                sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
                # 安装
                make install
                # 改正 ldd 脚本中硬编码的可执行文件加载器路径
                sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd
                # 安装 nscd 的配置文件和运行时目录
                cp -v ../nscd/nscd.conf /etc/nscd.conf
                mkdir -pv /var/cache/nscd
                # 安装 nscd 的 systemd 支持文件
                install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
                install -v -Dm644 ../nscd/nscd.service /usr/lib/systemd/system/nscd.service
                # 安装一些测试需要的 locale
                mkdir -pv /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f ISO-8859-1 en_GB
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_ES -f ISO-8859-15 es_ES@euro
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i is_IS -f ISO-8859-1 is_IS
localedef -i is_IS -f UTF-8 is_IS.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f ISO-8859-15 it_IT@euro
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i se_NO -f UTF-8 se_NO.UTF-8
localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
localedef -i zh_TW -f UTF-8 zh_TW.UTF-8GB18030

                # 配置glibc
                # --------
                # 创建 nsswitch.conf
                cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

                # 添加时区数据
                tar -xvf /sources/_LFS_VERSION/tzdata2022c.tar.gz

                ZONEINFO=/usr/share/zoneinfo
                mkdir -pv $ZONEINFO/{posix,right}

                for tz in etcetera southamerica northamerica europe africa antarctica  \
                        asia australasia backward; do
                    zic -L /dev/null   -d $ZONEINFO       ${tz}
                    zic -L /dev/null   -d $ZONEINFO/posix ${tz}
                    zic -L leapseconds -d $ZONEINFO/right ${tz}
                done

                cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
                zic -d $ZONEINFO -p America/New_York
                unset ZONEINFO

                # 创建 /etc/localtime
                ln -sfv /usr/share/zoneinfo/America/New_York /etc/localtime

                # 配置动态加载器
                mkdir -pv /etc/ld.so.conf.d
                cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF

                # 写入完成标志
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
    PKG_NAME=zlib
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr
            [ $? = 0 ] && make -j_LFS_BUILD_PROC
            [ $? = 0 ] && make -j_LFS_BUILD_PROC check && read -p "$PKG_NAME CHECK DONE..."
            [ $? = 0 ] && make install
            if [ $? = 0 ]; then
                rm -fv /usr/lib/libz.a
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
    PKG_NAME=bzip2
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            find ../.. -maxdepth 1 -type f -name "$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
            [ $? != 0 ] && exit 1
        popd
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            # 保证安装的符号链接是相对的
            sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
            # 确保 man 页面被安装到正确位置
            sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
            # 准备编译
            make -f Makefile-libbz2_so
            make clean
            # 编译
            [ $? = 0 ] && make -j_LFS_BUILD_PROC
            [ $? = 0 ] && make PREFIX=/usr install
            if [ $? = 0 ]; then
                # 安装共享库
                cp -av libbz2.so.* /usr/lib
                ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so
                # 安装链接到共享库的 bzip2 二进制程序到 /bin 目录
                cp -v bzip2-shared /usr/bin/bzip2
                for i in /usr/bin/{bzcat,bunzip2}; do
                    ln -sfv bzip2 $i
                done
                # 删除无用的静态库
                rm -fv /usr/lib/libbz2.a

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
    PKG_NAME=xz
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/xz-5.2.6
            [ $? = 0 ] && make -j_LFS_BUILD_PROC
            [ $? = 0 ] && make -j_LFS_BUILD_PROC check && read -p "$PKG_NAME CHECK DONE..."
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
    PKG_NAME=zstd
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            find ../.. -maxdepth 1 -type f -name "$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
            [ $? != 0 ] && exit 1
        popd
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            [ $? = 0 ] && make -j_LFS_BUILD_PROC
            [ $? = 0 ] && make -j_LFS_BUILD_PROC check && read -p "$PKG_NAME CHECK DONE..."
            [ $? = 0 ] && make prefix=/usr install
            if [ $? = 0 ]; then
                rm -v /usr/lib/libzstd.a
                read -p "$PKG_NAME ALL DONE..."
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
