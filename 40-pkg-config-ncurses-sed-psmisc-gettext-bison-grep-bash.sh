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
    PKG_NAME=pkg-config
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --with-internal-glib    \
                --disable-host-tool     \
                --docdir=/usr/share/doc/pkg-config
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
    PKG_NAME=ncurses
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --mandir=/usr/share/man \
                --with-shared           \
                --without-debug         \
                --without-normal        \
                --enable-pc-files       \
                --enable-widec          \
                --with-pkg-config-libdir=/usr/lib/pkgconfig
            make -j_LFS_BUILD_PROC
            make DESTDIR=$PWD/dest install
            install -vm755 dest/usr/lib/libncursesw.so.6.3 /usr/lib
            rm -v  dest/usr/lib/{libncursesw.so.6.3,libncurses++w.a}
            cp -av dest/* /

            for lib in ncurses form panel menu ; do
                rm -vf                    /usr/lib/lib${lib}.so
                echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
                ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
            done

            rm -vf                     /usr/lib/libcursesw.so
            echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
            ln -sfv libncurses.so      /usr/lib/libcurses.so

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
    PKG_NAME=sed
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_2/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_2
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make html
            if [ $? = 0 ]; then
                chown -Rv tester .
                su tester -c "PATH=$PATH make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check"
                make install
                install -d -m755           /usr/share/doc/sed-4.8
                install -m644 doc/sed.html /usr/share/doc/sed-4.8
                touch build_2/_BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=psmisc
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage3
        PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make install
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
    PKG_NAME=gettext
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_2/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_2
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr   \
                --disable-static        \
                --docdir=/usr/share/doc/gettext
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                chmod -v 0755 /usr/lib/preloadable_libintl.so
                touch build_2/_BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=bison
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_2/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_2
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.8.2
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch build_2/_BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=grep
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_2/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_2
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch build_2/_BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd


pushd /sources/_LFS_VERSION
    PKG_NAME=bash
    PKG_PATH=$(find stage3 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_2/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_2
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr           \
                --docdir=/usr/share/doc/bash    \
                --without-bash-malloc           \
                --with-installed-readline
            make -j_LFS_BUILD_PROC || exit 99
            chown -Rv tester .
            su -s /usr/bin/expect tester << EOF
set timeout -1
spawn make tests
expect eof
lassign [wait] _ _ _ value
exit $value
EOF
            make install
            if [ $? = 0 ]; then
                echo exit | exec /usr/bin/bash --login
                touch build_2/_BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
