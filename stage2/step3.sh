#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step3
# chroot进去继续干
#

echo -e "\033[31mKILL 28-libstdcxx.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../28-libstdcxx.sh
echo DONE
echo

echo -e "\033[31mKILL 29-gettext-bison.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../29-gettext-bison.sh
echo DONE
echo

echo -e "\033[31mKILL 30-perl-python.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../30-perl-python.sh
echo DONE
echo

echo -e "\033[31mKILL 31-texinfo-util-linux.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../31-texinfo-util-linux.sh
echo DONE
echo

echo -e "\033[31mKILL 32-clean-backup.sh ...\033[0m"
source `dirname ${BASH_SOURCE[0]}`/../32-clean-backup.sh
echo DONE
echo
