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
    PKG_NAME=systemd
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.gz")
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            find ../.. -maxdepth 1 -type f -name "$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
            [ $? = 0 ] || exit 1
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed -i -e 's/GROUP="render"/GROUP="video"/' \
                   -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in
            mkdir -p build
            cd       build

            meson --prefix=/usr               \
                --sysconfdir=/etc             \
                --localstatedir=/var          \
                --buildtype=release           \
                -Dblkid=true                  \
                -Ddefault-dnssec=no           \
                -Dfirstboot=false             \
                -Dinstall-tests=false         \
                -Dldconfig=false              \
                -Dsysusers=false              \
                -Db_lto=false                 \
                -Drpmmacrosdir=no             \
                -Dhomed=false                 \
                -Duserdb=false                \
                -Dman=false                   \
                -Dmode=release                \
                -Ddocdir=/usr/share/doc/systemd-250 \
                ..

            ninja -j_LFS_BUILD_PROC && ninja install
            if [ $? = 0 ]; then
                tar -xpvf $(find ../.. -maxdepth 1 -type f -name "$PKG_NAME-man-*.tar.*") --strip-components=1 -C /usr/share/man
                rm -rf /usr/lib/pam.d
                systemd-machine-id-setup
                systemctl preset-all
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
