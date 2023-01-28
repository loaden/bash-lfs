#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step2
# 内核编译
#

echo KILL 62-linux.sh ...
bash `dirname ${BASH_SOURCE[0]}`/../62-linux.sh
[ $? = 0 ] || exit 2
echo DONE
echo
