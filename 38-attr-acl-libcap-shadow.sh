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
    PKG_NAME=attr
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr     \
                --disable-static  \
                --sysconfdir=/etc \
                --docdir=/usr/share/doc/attr-2.5.1
            [ $? = 0 ] && make -j_LFS_BUILD_PROC
            [ $? = 0 ] && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && read -p "$PKG_NAME CHECK DONE..."
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
    PKG_NAME=acl
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr \
                --disable-static      \
                --docdir=/usr/share/doc/acl-2.3.1

            [ $? = 0 ] && make -j_LFS_BUILD_PROC
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
    PKG_NAME=libcap
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            # 防止静态库的安装
            sed -i '/install -m.*STA/d' libcap/Makefile

            [ $? = 0 ] && prefix=/usr lib=lib
            [ $? = 0 ] && make test && read -p "$PKG_NAME CHECK DONE..."
            [ $? = 0 ] && make prefix=/usr lib=lib install
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
    PKG_NAME=shadow
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            # 禁止该软件包安装 groups 程序和它的 man 页面，因为 Coreutils 会提供更好的版本
            sed -i 's/groups$(EXEEXT) //' src/Makefile.in
            find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
            find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
            find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

            # 不使用默认的 crypt 加密方法
            sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
                -e 's:/var/spool/mail:/var/mail:'                 \
                -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                \
                -i etc/login.defs

            touch /usr/bin/passwd
            ./configure --sysconfdir=/etc \
                --disable-static  \
                --with-group-name-max-length=32

            [ $? = 0 ] && make
            [ $? = 0 ] && make exec_prefix=/usr install
            [ $? = 0 ] && make -C man install-man
            if [ $? = 0 ]; then
                # 对用户密码启用 Shadow 加密
                pwconv
                # 对组密码启用 Shadow 加密
                grpconv
                # 修改默认参数
                mkdir -p /etc/default
                useradd -D --gid 999
                sed -i '/MAIL/s/yes/no/' /etc/default/useradd
                # 设置root密码
                echo "设置root用户密码"
                passwd root

                read -p "$PKG_NAME ALL DONE..."
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
