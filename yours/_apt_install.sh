#! /bin/sh
# $1: target directory
# $2: apt package(s)
# $3: a flag of configure
if apt-get install -yq --no-install-recommends ${2} ; then
    grep -- "${3}" ${1}/_enable_if_available > /dev/null || \
        echo ${3} >> ${1}/_enable_if_available
else
    true
fi
