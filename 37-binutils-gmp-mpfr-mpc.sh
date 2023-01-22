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
        expect -c "spawn ls"
        read -p "必须输出：spawn ls 才能继续"

        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            ../configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --enable-gold       \
                --enable-ld=default \
                --enable-plugins    \
                --enable-shared     \
                --disable-werror    \
                --enable-64-bit-bfd \
                --with-system-zlib

            [ $? = 0 ] && make tooldir=/usr
            [ $? = 0 ] && make -k check
            [ $? = 0 ] && make tooldir=/usr install
            if [ $? = 0 ]; then
                # 删除无用的静态库
                rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
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
    PKG_NAME=gmp
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr    \
                --enable-cxx     \
                --disable-static \
                --docdir=/usr/share/doc/gmp-6.2.1
            make && make html && make check 2>&1 | tee gmp-check-log
            [ $? = 0 ] && make && make html
            [ $? = 0 ] && make check 2>&1 | tee gmp-check-log
            if [ $? = 0 ]; then
                # 务必确认测试全部通过
                awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
                echo "务必确认测试全部通过"
                read -p "$PKG_NAME CHECK DONE..."
            fi

            [ $? = 0 ] && make install && make install-html
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
    PKG_NAME=mpfr
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr        \
                --disable-static     \
                --enable-thread-safe \
                --docdir=/usr/share/doc/mpfr-4.1.0
            [ $? = 0 ] && make && make html
            [ $? = 0 ] && make check
            if [ $? = 0 ]; then
                echo "务必确认测试全部通过"
                read -p "$PKG_NAME CHECK DONE..."
            fi

            [ $? = 0 ] && make install && make install-html
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
    PKG_NAME=mpc
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr    \
                --disable-static \
                --docdir=/usr/share/doc/mpc-1.2.1
            make -j_LFS_BUILD_PROC && make html && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check
            [ $? = 0 ] && make && make html
            [ $? = 0 ] && make check && read -p "$PKG_NAME CHECK DONE..."
            [ $? = 0 ] && make install && make install-html
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
