#! /bin/sh
# $1: target category
# $2: apt package(s)
# $3: alternative package(s) if $2 is not available
# $4: a flag of configure

# note that i want to log requests of "apt-get install", not actually installed.
destdir="`dirname \"$0\"`"
logfn=$0.req-log
if apt-get install -yq --no-install-recommends ${2} ; then
    grep -- "${4}" ${destdir}/_enable_if_available > /dev/null || \
        echo "${1}:"${4} >> ${destdir}/_enable_if_available
        echo $2 | sed 's@  *@\
@g' | sed 's@-dev$@@' >> ${logfn}
elif test "z$3" != "z" ; then
    if apt-get install -yq --no-install-recommends ${3} ; then
        grep -- "${4}" ${destdir}/_enable_if_available > /dev/null || \
            echo "${1}:"${4} >> ${destdir}/_enable_if_available
        echo $3 | sed 's@  *@\
@g' | sed 's@-dev$@@' >> ${logfn}
    else
        true
    fi
else
    true
fi
