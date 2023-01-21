#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step2
# 完成C和C++交叉编译器构建
#

echo -e "\033[31mKILL 05-binutils.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../05-binutils.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 06-gcc.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../06-gcc.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 07-linux-api.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../07-linux-api.sh
[ $? = 0 ] || exit 2
echo DONE
echo
