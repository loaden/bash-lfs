#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

umount -R $LFS
[ ! -e /etc/bash.bashrc.bak ] || mv -v /etc/bash.bashrc.bak /etc/bash.bashrc
