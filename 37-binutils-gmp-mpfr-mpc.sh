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
    PKG_NAME=binutils
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            expect -c "spawn ls"
            read -p "必须输出：spawn ls 才能任意键继续"
            sed -e '/R_386_TLS_LE /i \   || (TYPE) == R_386_TLS_IE \\' \
                -i $PKG_PATH/bfd/elfxx-x86.h
            ../configure --prefix=/usr  \
                --enable-gold           \
                --enable-ld=default     \
                --enable-plugins        \
                --enable-shared         \
                --disable-werror        \
                --enable-64-bit-bfd     \
                --with-system-zlib
            CUR_MAKE_JOBS=$(echo _LFS_BUILD_PROC - 1 | bc)
            make -j$CUR_MAKE_JOBS tooldir=/usr && make -j$CUR_MAKE_JOBS -k check && make tooldir=/usr install
            if [ $? = 0 ]; then
                rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=gmp
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --enable-cxx            \
                --disable-static        \
                --docdir=/usr/share/doc/gmp
            make -j_LFS_BUILD_PROC && make html && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check 2>&1 | tee gmp-check-log
            awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
            make install
            make install-html
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=mpfr
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --disable-static        \
                --enable-thread-safe    \
                --docdir=/usr/share/doc/mpfr
            make -j_LFS_BUILD_PROC && make html && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check
            if [ $? = 0 ]; then
                make install
                make install-html
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=mpc
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --disable-static        \
                --docdir=/usr/share/doc/mpc
            make -j_LFS_BUILD_PROC && make html && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check
            if [ $? = 0 ]; then
                make install
                make install-html
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
