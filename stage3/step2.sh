#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step2
# stage3开工了，构建其他基础工具
#

echo -e "\033[31mKILL 38-pkg-config-ncurses-sed-psmisc-gettext-bison-grep-bash.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../38-pkg-config-ncurses-sed-psmisc-gettext-bison-grep-bash.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 39-libtool-gdbm-gperf-expat-inetutils-less-perl.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../39-libtool-gdbm-gperf-expat-inetutils-less-perl.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 40-intltool-autoconf-automake-openssl-kmod-libffi-Python-ninja-meson-coreutils-check-diffutils.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../40-intltool-autoconf-automake-openssl-kmod-libffi-Python-ninja-meson-coreutils-check-diffutils.sh
[ $? = 0 ] || exit 2
echo DONE
echo
