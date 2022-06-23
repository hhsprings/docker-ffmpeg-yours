#! /bin/sh
# $1: target category
# $2: apt package(s)
# $3: alternative package(s) if $2 is not available
# $4: a flag of configure

# note that i want to log requests of "apt-get install", not actually installed.
destdir="`dirname \"$0\"`"
logfn=$0.req-log

_pkg_exists() {
    for p in ${1} ; do
        apt-cache policy $p | grep Candidate || return 1
    done
    return 0
}

#
# The package may not exist because it depends on the distro.
# In that case, "Non-existence" of "$2" or "$3" should not be
# regarded as an error. On the other hand, if we know it exists
# and its installation fails, we should treat it as an error.
# Network communication timeouts are the most likely error,
# and in fact this has caused me to make a mistake in the
# --enable-sdl2 related decision.
#
if _pkg_exists "${2}" ; then
    apt-get install -y -qq --no-install-recommends ${2} && \
        (grep -- "${4}" ${destdir}/_enable_if_available > /dev/null || \
                echo "${1}:"${4} >> ${destdir}/_enable_if_available ; \
         echo $2 | sed 's@  *@\
@g' >> ${logfn})
elif test "z$3" != "z" && _pkg_exists "${3}" ; then
    apt-get install -y -qq --no-install-recommends ${3} && \
        (grep -- "${4}" ${destdir}/_enable_if_available > /dev/null || \
                echo "${1}:"${4} >> ${destdir}/_enable_if_available ; \
         echo $3 | sed 's@  *@\
@g' >> ${logfn})
else
    true
fi
