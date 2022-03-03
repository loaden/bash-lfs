#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 安排战术
IFS='' read -r -d '' HAVE_WORK_TODO <<EOF
pushd /sources/$(getConf LFS_VERSION)
    PKG_NAME=perl
    PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
    if [ -z \$PKG_PATH ]; then
        tar -xpvf \$(find . -maxdepth 1 -type f -name "\$PKG_NAME-*.tar.*")
        PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
        pushd \$PKG_PATH
            find .. -maxdepth 1 -type f -name "\$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
            [ \$? != 0 ] && exit 1
        popd
    fi

    if [ ! -f \$PKG_PATH/_BUILD_DONE ]; then
        pushd \$PKG_PATH
            sh Configure -des                                       \
                        -Dprefix=/usr                               \
                        -Dvendorprefix=/usr                         \
                        -Dprivlib=/usr/lib/perl5/5.34/core_perl     \
                        -Darchlib=/usr/lib/perl5/5.34/core_perl     \
                        -Dsitelib=/usr/lib/perl5/5.34/site_perl     \
                        -Dsitearch=/usr/lib/perl5/5.34/site_perl    \
                        -Dvendorlib=/usr/lib/perl5/5.34/vendor_perl \
                        -Dvendorarch=/usr/lib/perl5/5.34/vendor_perl
            make -j$LFS_BUILD_PROC && make install
            if [ \$? = 0 ]; then
                touch _BUILD_DONE
            else
                exit 1
            fi
        popd
    fi
popd

pushd /sources/$(getConf LFS_VERSION)
    PKG_NAME=Python
    PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
    if [ -z \$PKG_PATH ]; then
        tar -xpvf \$(find . -maxdepth 1 -type f -name "\$PKG_NAME-*.tar.*")
        PKG_PATH=\$(find . -maxdepth 1 -type d -name "\$PKG_NAME-*")
    fi

    if [ ! -f \$PKG_PATH/_BUILD_DONE ]; then
        pushd \$PKG_PATH
            ./configure --prefix=/usr   \
                --enable-shared         \
                --without-ensurepip
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