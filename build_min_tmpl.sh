#! /bin/sh
suites=${1}
export __push=$(if test "z${2:-''}" = "z--push" ; then echo true ; else echo false ; fi)
export _YOU=${_YOU:-hhsprings}
export _VER_MIN=${_VER_MIN:-0.5.2}
export _BUILDPACKDEPS_TAG_FOR_LATEST=22.10
export _FFMPEG_VERSION_FOR_LATEST=4.4.2
cd min

for _FFMPEG_VERSION in 4.4.2 3.4.11 4.1.9 4.2.7 4.3.4 ; do
    for _BUILDPACKDEPS_TAG in ${suites} ; do

        export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_MIN}-min
        r="${_YOU}/ffmpeg-yours-min"
        t="${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}"
        #
        if curl -s https://registry.hub.docker.com/v1/repositories/${r}/tags | sed 's@\("name": \)@\
\1@g' | grep ^'"name' | sed 's@^"name": "\([^"]*\)".*@\1@' | \
            grep "^${t}$" ; then
            echo "${t}: already exits"
        else
            t_opt="-t ${r}:${t} -t ${r}:latest-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}"
            if test "${_BUILDPACKDEPS_TAG}" = "${_BUILDPACKDEPS_TAG_FOR_LATEST}" -a \
                    ${_FFMPEG_VERSION} = "{_FFMPEG_VERSION_FOR_LATEST}" ; then
                t_opt="${t_opt} -t ${r}:latest"
            fi
            docker buildx build -f Dockerfile \
                   ${t_opt} \
                   --build-arg _BUILDPACKDEPS_TAG=${_BUILDPACKDEPS_TAG} \
                   --build-arg _FFMPEG_VERSION=${_FFMPEG_VERSION} \
                   --build-arg _FFMPEG_EXTRA_VERSION_SUFFIX=${_FFMPEG_EXTRA_VERSION_SUFFIX} \
                   --platform linux/amd64 \
                   -o type=image,push=${__push} \
                   . || exit $?

            if test $? -eq 0 && test ${__push} = "true" ; then
                docker run -t --rm ${r}:${t} ffmpeg -version
            fi
        fi
    done
    docker buildx prune -a -f
done
