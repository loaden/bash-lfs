#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

apt install build-essential -y
apt install bison -y
apt install gawk -y
apt install texinfo -y
apt install bc -y
apt install automake -y
apt autopurge -y

echo
ln -sf /usr/bin/bash /bin/sh
source `dirname ${BASH_SOURCE[0]}`/version-check.sh
