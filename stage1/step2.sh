#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step2
# 完成交叉工具链和临时工具的构建
#

echo -e "\033[31mKILL 05-binutils.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../05-binutils.sh
echo DONE
echo

echo -e "\033[31mKILL 06-gcc.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../06-gcc.sh
echo DONE
echo

echo -e "\033[31mKILL 07-linux-api.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../07-linux-api.sh
echo DONE
echo

echo -e "\033[31mKILL 08-glibc.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../08-glibc.sh
echo DONE
echo
