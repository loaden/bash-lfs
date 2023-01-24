#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# stage5
sudo `dirname ${BASH_SOURCE[0]}`/stage5/step1.sh
[ $? = 0 ] || exit 3
sudo `dirname ${BASH_SOURCE[0]}`/stage5/step2.sh
[ $? = 0 ] || exit 3
