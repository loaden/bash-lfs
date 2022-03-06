#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step1
# stage3开工了，重新构建所有
#

echo -e "\033[31mKILL 33-man-pages-iana-etc.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../33-man-pages-iana-etc.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 34-glibc-zlib-bzip2.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../34-glibc-zlib-bzip2.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo -e "\033[31mKILL 35-xz-zstd-file-readline-m4-bc-flex.sh ...\033[0m"
bash `dirname ${BASH_SOURCE[0]}`/../35-xz-zstd-file-readline-m4-bc-flex.sh
[ $? = 0 ] || exit 2
echo DONE
echo
