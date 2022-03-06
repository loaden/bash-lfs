#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step1
# 用交叉编译器构建目标系统基本工具
#

echo -e "\033[31mKILL 10-m4.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../10-m4.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 11-ncurses.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../11-ncurses.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 12-bash.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../12-bash.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 13-coreutils.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../13-coreutils.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 14-diffutils.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../14-diffutils.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 15-file.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../15-file.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 16-findutils.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../16-findutils.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 17-gawk.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../17-gawk.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 18-grep.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../18-grep.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 19-gzip.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../19-gzip.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 20-make.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../20-make.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 21-patch.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../21-patch.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 22-sed.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../22-sed.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 23-tar.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../23-tar.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 24-xz.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../24-xz.sh
[ $? = 0 ] || exit 2
echo DONE
echo
