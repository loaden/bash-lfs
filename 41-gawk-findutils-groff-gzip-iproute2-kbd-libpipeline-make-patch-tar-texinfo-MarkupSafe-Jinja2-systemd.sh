#!/bin/bash
# QQ群：111601117、钉钉群：35948877

if [ ! -f $LFS/task.sh ]; then
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
    PKG_NAME=gawk
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            sed -i 's/extras//' Makefile.in
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=findutils
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            case $(uname -m) in
                i?86)   TIME_T_32_BIT_OK=yes ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
                x86_64) ./configure --prefix=/usr --localstatedir=/var/lib/locate ;;
            esac
            make -j_LFS_BUILD_PROC || exit 99
            chown -Rv tester .
            su tester -c "PATH=$PATH make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check"
            if [ $? = 0 ]; then
                make install
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=groff
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            PAGE=A4 ./configure --prefix=/usr
            make -j1 && make install
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
    PKG_NAME=gzip
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=iproute2
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed -i /ARPD/d Makefile
            rm -fv man/man8/arpd.8
            make -j_LFS_BUILD_PROC && make SBINDIR=/usr/sbin install
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
    PKG_NAME=kbd
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            find .. -maxdepth 1 -type f -name "$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
            [ $? = 0 ] || exit 1
        popd
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
            sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
            ./configure --prefix=/usr --disable-vlock
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
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
    PKG_NAME=libpipeline
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
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
    PKG_NAME=make
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=patch
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=tar
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE_2
            else
                pwd
                read -p "FIXME: tar 部分测试失败，手动任意键继续..."
                touch _BUILD_DONE_2
                make install || exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=texinfo
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr
            sed -e 's/__attribute_nonnull__/__nonnull/' \
                -i gnulib/lib/malloc/dynarray-skeleton.c
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                make TEXMF=/usr/share/texmf install-tex
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=MarkupSafe
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            python3 setup.py build
            python3 setup.py install --optimize=1
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
    PKG_NAME=Jinja2
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            python3 setup.py install --optimize=1
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
    PKG_NAME=systemd
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.gz")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            find .. -maxdepth 1 -type f -name "$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
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
