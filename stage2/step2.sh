#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step2
# 用交叉编译器构建目标系统编译器
#

echo -e "\033[31mKILL 25-binutils.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../25-binutils.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 26-gcc.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../26-gcc.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 27-prepare-chroot.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../27-init-chroot.sh
[ $? = 0 ] || exit 2
echo DONE
echo
