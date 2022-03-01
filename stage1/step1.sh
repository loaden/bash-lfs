#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step1
# 完成环境检测、挂载、源码下载与校验、用户与目录建立工作
#

echo KILL 01-version-check.sh ...
source `dirname ${BASH_SOURCE[0]}`/../01-version-check.sh
echo DONE
echo

echo KILL 02-mount.sh ...
source `dirname ${BASH_SOURCE[0]}`/../02-mount.sh
echo DONE
echo

echo KILL 03-download-srcs.sh ...
source `dirname ${BASH_SOURCE[0]}`/../03-download-srcs.sh
echo DONE
echo

echo KILL 04-dir-users.sh ...
source `dirname ${BASH_SOURCE[0]}`/../04-dir-users.sh
echo DONE
echo
