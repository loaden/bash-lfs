#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# stage1
sudo `dirname ${BASH_SOURCE[0]}`/stage1.sh
[ $? = 0 ] || exit 4

# stage2
sudo `dirname ${BASH_SOURCE[0]}`/stage2.sh
[ $? = 0 ] || exit 4

# stage3
sudo `dirname ${BASH_SOURCE[0]}`/stage3.sh
[ $? = 0 ] || exit 4

# stage4
sudo `dirname ${BASH_SOURCE[0]}`/stage4.sh
[ $? = 0 ] || exit 4

# stage5
sudo `dirname ${BASH_SOURCE[0]}`/stage5.sh
[ $? = 0 ] || exit 4
