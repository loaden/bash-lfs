#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step1
# lfs基础配置
#

echo KILL 61-config.sh ...
bash `dirname ${BASH_SOURCE[0]}`/../61-config.sh
[ $? = 0 ] || exit 2
echo DONE
echo
