#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step2
# 构建出最终版的GCC
#

echo -e "\033[31mKILL 33-man-pages-iana-etc.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../33-man-pages-iana-etc.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 34-glibc-zlib-bzip2-xz-zstd.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../34-glibc-zlib-bzip2-xz-zstd.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 35-file-readline-m4-bc.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../35-file-readline-m4-bc.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 36-flex-tcl-expect-dejagnu.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../36-flex-tcl-expect-dejagnu.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 37-binutils-gmp-mpfr-mpc.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../37-binutils-gmp-mpfr-mpc.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 38-attr-acl-libcap-shadow.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../38-attr-acl-libcap-shadow.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 39-gcc.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../39-gcc.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 40-libtool-gdbm-gperf-expat.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../40-libtool-gdbm-gperf-expat.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 41-inetutils-less-perl-XML-Parser.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../41-inetutils-less-perl-XML-Parser.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 42-pkg-config-ncurses-sed-psmisc.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../42-pkg-config-ncurses-sed-psmisc.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 43-gettext-bison-grep-bash.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../43-gettext-bison-grep-bash.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 44-intltool-autoconf-automake.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../44-intltool-autoconf-automake.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 45-openssl-kmod-elfutils.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../45-openssl-kmod-elfutils.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 46-libffi-Python-ninja-meson.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../46-libffi-Python-ninja-meson.sh
[ $? = 0 ] || exit 2
echo DONE
echo
