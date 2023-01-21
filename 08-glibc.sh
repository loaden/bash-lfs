#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 配置LFS用户编译任务
if [ "$USER" != "lfs" ]; then
    cp "$LFS_PROJECT/`basename ${BASH_SOURCE[0]}`" /home/lfs/build.sh
    cp "$LFS_PROJECT/lfs.sh" /home/lfs/
    cp "$LFS_PROJECT/lfs.conf" /home/lfs/
    chown lfs:lfs /home/lfs/build.sh
    chown lfs:lfs /home/lfs/lfs.sh
    chown lfs:lfs /home/lfs/lfs.conf
    [ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
    su - lfs
    [ ! -e /etc/bash.bashrc.NOUSE ] || mv -v /etc/bash.bashrc.NOUSE /etc/bash.bashrc
    rm -f /home/lfs/build.sh
    rm -f /home/lfs/lfs.sh
    rm -f /home/lfs/lfs.conf
    exit
fi

# 来自lfs用户的调用
pushd $LFS/sources/$(getConf LFS_VERSION)
    PKG_NAME=glibc
    PKG_PATH=$(find stage2 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage2
        PKG_PATH=$(find stage2 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            find ../.. -maxdepth 1 -type f -name "$PKG_NAME-*.patch" -exec patch -Np1 -i {} \;
            [ $? != 0 ] && exit 1
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            case $(uname -m) in
                i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
                ;;
                x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                        ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
                ;;
            esac

            # 确保将 ldconfig 和 sln 工具安装到 /usr/sbin 目录中
            echo "rootsbindir=/usr/sbin" > configparms
            ../configure                           \
                --prefix=/usr                      \
                --host=$LFS_TGT                    \
                --build=$(../scripts/config.guess) \
                --enable-kernel=3.2                \
                --with-headers=$LFS/usr/include    \
                libc_cv_slibdir=/usr/lib

            # 必须单线程编译
            make -j1 && make DESTDIR=$LFS install

            if [ $? = 0 ]; then
                # 改正 ldd 脚本中硬编码的可执行文件加载器路径
                sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
                # 检查，应该输出
                # [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
                # 32 位机器，解释器的名字将会是 /lib/ld-linux.so.2
                # 还要检查gcc的位置是否来自$LFS
                whereis $LFS_TGT-gcc
                echo 'int main(){}' | $LFS_TGT-gcc -xc -
                readelf -l a.out | grep ld-linux
                rm -v a.out
                sleep 5
                # 完成 limits.h 头文件的安装
                $LFS/tools/libexec/gcc/$LFS_TGT/12.2.0/install-tools/mkheaders
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
