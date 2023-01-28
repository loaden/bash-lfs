#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step3
# GRUB与收后
#

echo KILL 63-grub-final.sh ...
bash `dirname ${BASH_SOURCE[0]}`/../63-grub-final.sh
[ $? = 0 ] || exit 2
echo DONE
echo
