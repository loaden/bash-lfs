#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step3
# 完成stage3
#

echo -e "\033[31mKILL 32-clean-backup.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../32-clean-backup.sh
[ $? = 0 ] || exit 2
echo DONE
echo
