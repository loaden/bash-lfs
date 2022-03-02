#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step1
# 用交叉编译器构建目标系统基本工具
#

echo -e "\033[31mKILL 10-m4.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../10-m4.sh
echo DONE
echo

echo -e "\033[31mKILL 11-ncurses.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../11-ncurses.sh
echo DONE
echo
