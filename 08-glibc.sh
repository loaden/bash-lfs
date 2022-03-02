#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 配置LFS用户编译任务
if [ "$USER" != "lfs" ]; then
    cat > /home/lfs/build.sh <<EOF
#!/bin/bash
exec $LFS_PROJECT/`basename ${BASH_SOURCE[0]}`
exit $?
EOF
    chown lfs:lfs /home/lfs/build.sh
    chmod 0755 /home/lfs/build.sh
    su - lfs
    return
fi

# 来自lfs用户的调用
pushd $LFS/sources/$(getConf LFS_VERSION)
    PKG_NAME=glibc
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name $PKG_NAME-*.tar.*)
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            patch -p1 < $(find .. -maxdepth 1 -type f -name $PKG_NAME-*.patch)
            [ $? != 0 ] && exit 1
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            case $(uname -m) in
                x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
                ;;
            esac

            # 确保将 ldconfig 和 sln 工具安装到 /usr/sbin 目录中
            echo "rootsbindir=/usr/sbin" > configparms
            ../configure                            \
                --prefix=/usr                       \
                --host=$LFS_TGT                     \
                --build=$(../scripts/config.guess)  \
                --enable-kernel=3.2                 \
                --with-headers=$LFS/usr/include     \
                libc_cv_slibdir=/usr/lib

            make -j1 && make DESTDIR=$LFS install

            # 注意看这里的输出，必须类似：[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
            if [ $? = 0 ]; then
                sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
                echo 'int main(){}' > dummy.c
                $LFS_TGT-gcc dummy.c
                readelf -l a.out | grep '/ld-linux'
                [ $? != 0 ] && exit 1
                rm -v dummy.c a.out
                $LFS/tools/libexec/gcc/$LFS_TGT/$(getConf LFS_GCC_VERSION)/install-tools/mkheaders
                touch _BUILD_DONE
            else
                exit 1
            fi
        popd
    fi
popd
