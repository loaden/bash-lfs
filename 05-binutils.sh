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
    PKG_NAME=binutils
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name $PKG_NAME-*.tar.*)
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
        pushd $PKG_PATH
            patch -p1 < $(find $LFS/sources/$(getConf LFS_VERSION) -maxdepth 1 -type f -name $PKG_NAME-*.patch)
        popd
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            ../configure                        \
                --prefix=$LFS/tools             \
                --with-sysroot=$LFS             \
                --target=$LFS_TGT               \
                --disable-nls                   \
                --disable-werror
            make -j$LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            fi
        popd
    fi
popd
