#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step1
# 构建全新GCC
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
