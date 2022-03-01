#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

# 配置LFS用户编译任务
if [ "$USER" != "$LFS_USER" ]; then
    cat > $LFS_HOME/build.sh <<EOF
#!/bin/bash
exec $LFS_PROJECT/`basename ${BASH_SOURCE[0]}`
exit $?
EOF
    chown $LFS_USER:$LFS_USER $LFS_HOME/build.sh
    chmod 0755 $LFS_HOME/build.sh
    su - $LFS_USER
    return
fi

# 来自lfs用户的调用
pushd $LFS/sources/$(getConf LFS_VERSION)
    PKG_NAME=gcc
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_cxx/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_cxx
        pushd $PKG_PATH/build_cxx
            ../libstdc++-v3/configure           \
                --host=$LFS_TGT                 \
                --build=$(../config.guess)      \
                --prefix=/usr                   \
                --disable-multilib              \
                --disable-nls                   \
                --disable-libstdcxx-pch         \
                --enable-cxx-flags=-nostdinc++  \
                --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/$(getConf LFS_GCC_VERSION)
            make -j$LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                exit 1
            fi
        popd
    fi
popd
