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
    PKG_NAME=gcc
    PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*") --directory stage4
        PKG_PATH=$(find stage4 -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name mpfr-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "mpfr-*") mpfr
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name gmp-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "gmp-*") gmp
            tar -xpvf $(find ../.. -maxdepth 1 -type f -name mpc-*.tar.*)
            mv -v $(find . -maxdepth 1 -type d -name "mpc-*") mpc

            # 在 x86_64 上构建时，修改存放 64 位库的默认路径为 “lib”:
            case $(uname -m) in
                x86_64)
                    sed -e '/m64=/s/lib64/lib/' \
                        -i.orig gcc/config/i386/t-linux64
                ;;
            esac

            echo "---确认---"
            diff gcc/config/i386/t-linux64.orig gcc/config/i386/t-linux64
            echo "------"
            sleep 5
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH
            cd build
            ../configure --prefix=/usr   \
                LD=ld                    \
                --enable-languages=c,c++ \
                --disable-multilib       \
                --disable-bootstrap      \
                --with-system-zlib

            [ $? = 0 ] && make -j_LFS_BUILD_PROC

            if [ $? = 0 ]; then
                # 运行测试前要增加栈空间
                ulimit -s 32768
                # 以非特权用户身份测试编译结果，但出错时继续执行其他测试
                chown -Rv tester .
                su tester -c "PATH=$PATH make -k check"
                # 查看测试结果
                # 对比：https://www.linuxfromscratch.org/lfs/build-logs/
                ../contrib/test_summary | grep -A7 Summ
                read -p "$PKG_NAME CHECK DONE..."
            fi

            [ $? = 0 ] && make install

            if [ $? = 0 ]; then
                # 修正安装的头文件目录 (及其内容) 不正确的所有权
                chown -v -R root:root \
                    /usr/lib/gcc/$(gcc -dumpmachine)/12.2.0/include{,-fixed}
                # 创建一个 FHS 因 “历史原因” 要求的符号链接
                ln -svr /usr/bin/cpp /usr/lib
                # 创建一个兼容性符号链接，以支持在构建程序时使用链接时优化 (LTO)
                ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/12.2.0/liblto_plugin.so \
                    /usr/lib/bfd-plugins/

                # 确认编译和链接像我们期望的一样正常工作
                echo 'int main(){}' > dummy.c
                cc dummy.c -v -Wl,--verbose &> dummy.log
                # 输出 [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]
                echo ------
                readelf -l a.out | grep ': /lib'
                # 确认我们的设定能够使用正确的启动文件
                # 输出
                # /usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../lib/crt1.o succeeded
                # /usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../lib/crti.o succeeded
                # /usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../lib/crtn.o succeeded
                echo ------
                grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
                # 确认编译器能正确查找头文件
                # 输出
                # /usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/include
                # /usr/local/include
                # /usr/lib/gcc/x86_64-pc-linux-gnu/12.2.0/include-fixed
                # /usr/include
                echo ------
                grep -B4 '^ /usr/include' dummy.log
                # 确认新的链接器使用了正确的搜索路径
                # 输出
                # SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib64")
                # SEARCH_DIR("/usr/local/lib64")
                # SEARCH_DIR("/lib64")
                # SEARCH_DIR("/usr/lib64")
                # SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib")
                # SEARCH_DIR("/usr/local/lib")
                # SEARCH_DIR("/lib")
                # SEARCH_DIR("/usr/lib");
                echo ------
                grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
                # 确认我们使用了正确的 libc
                # 输出 attempt to open /usr/lib/libc.so.6 succeeded
                echo ------
                grep "/lib.*/libc.so.6 " dummy.log
                # 确认 GCC 使用了正确的动态链接器
                # 输出 found ld-linux-x86-64.so.2 at /usr/lib/ld-linux-x86-64.so.2
                echo ------
                grep found dummy.log
                # 删除测试文件
                read -p "这里出现的任何问题在继续构建前都必须解决，耐心的检查日志..."
                rm -v dummy.c a.out dummy.log

                # 移动一个位置不正确的文件
                mkdir -pv /usr/share/gdb/auto-load/usr/lib
                mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

                read -p "$PKG_NAME ALL DONE..."
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
