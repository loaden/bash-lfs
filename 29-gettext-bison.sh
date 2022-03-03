#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 安排战术
IFS='' read -r -d '' HAVE_WORK_TODO <<EOF
pushd /sources/$(getConf LFS_VERSION)
    PKG_NAME=gettext
    PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
    if [ -z \$PKG_PATH ]; then
        tar -xpvf \$(find . -maxdepth 1 -type f -name "\$PKG_NAME-*.tar.*")
        PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
    fi

    if [ ! -f \$PKG_PATH/_BUILD_DONE ]; then
        pushd \$PKG_PATH
            ./configure --disable-shared
            make -j$LFS_BUILD_PROC
            if [ \$? = 0 ]; then
                cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
                touch _BUILD_DONE
            else
                exit 1
            fi
        popd
    fi
popd

pushd /sources/$(getConf LFS_VERSION)
    PKG_NAME=bison
    PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
    if [ -z \$PKG_PATH ]; then
        tar -xpvf \$(find . -maxdepth 1 -type f -name "\$PKG_NAME-*.tar.*")
        PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
    fi

    if [ ! -f \$PKG_PATH/_BUILD_DONE ]; then
        pushd \$PKG_PATH
            ./configure --prefix=/usr \
                --docdir=/usr/share/doc/bison-3.8.2
            make -j$LFS_BUILD_PROC && make install
            if [ \$? = 0 ]; then
                touch _BUILD_DONE
            else
                exit 1
            fi
        popd
    fi
popd

# 安排完毕
EOF

# 战斗啦
source `dirname ${BASH_SOURCE[0]}`/chroot.sh "$HAVE_WORK_TODO"
