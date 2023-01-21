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

echo -e "\033[31mKILL 28-libstdcxx.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../28-libstdcxx.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 29-gettext-bison.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../29-gettext-bison.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 30-perl-python.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../30-perl-python.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 31-texinfo-util-linux.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../31-texinfo-util-linux.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 32-clean-backup.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../32-clean-backup.sh
[ $? = 0 ] || exit 2
echo DONE
echo
