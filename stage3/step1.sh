#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step1
# chroot进去继续干
#

echo -e "\033[31mKILL 27-prepare-chroot.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../27-init-chroot.sh
[ $? = 0 ] || exit 2
echo DONE
echo
