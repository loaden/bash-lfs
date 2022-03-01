#!/bin/bash
# QQ群：111601117、钉钉群：35948877

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

umount -R $LFS

if [ -e /etc/bash.bashrc.bak ]; then
    mv -v /etc/bash.bashrc.bak /etc/bash.bashrc
fi
