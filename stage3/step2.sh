#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step2
# 补充stage3缺失工具
#

echo -e "\033[31mKILL 29-gettext-bison.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../29-gettext-bison.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 30-perl-python.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../30-perl-python.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 31-texinfo-util-linux.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../31-texinfo-util-linux.sh
[ $? = 0 ] || exit 2
echo DONE
echo
