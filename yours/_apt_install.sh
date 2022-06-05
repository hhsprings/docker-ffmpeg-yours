#! /bin/sh
# $1: target directory
# $2: apt package(s)
# $3: alternative package(s) if $2 is not available
# $4: a flag of configure
if apt-get install -yq --no-install-recommends ${2} ; then
    grep -- "${4}" ${1}/_enable_if_available > /dev/null || \
        echo ${4} >> ${1}/_enable_if_available
else
    if test "z$3" != "z" ; then
        if apt-get install -yq --no-install-recommends ${3} ; then
            grep -- "${4}" ${1}/_enable_if_available > /dev/null || \
                echo ${4} >> ${1}/_enable_if_available
        else
            true
    else
        true
    fi
fi
