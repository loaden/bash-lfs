#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step3
# 清理
#

echo -e "\033[31mKILL 55-strip-clean.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../55-strip-clean.sh
[ $? = 0 ] || exit 2
echo DONE
echo
