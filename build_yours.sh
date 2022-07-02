#! /bin/sh
export __push=$(if test "z${1:-''}" = "z--push" ; then echo true ; else echo false ; fi)
export _YOU=${_YOU:-hhsprings}
export _VER_YOURS=0.8.14
export _BUILDPACKDEPS_TAG_FOR_LATEST=22.10
export _FFMPEG_VERSION_FOR_LATEST=5.0.1

cd yours
for _BUILDPACKDEPS_TAG in 22.10 22.04 ; do
    for _FFMPEG_VERSION in 5.0.1 4.4.2 ; do
        docker buildx prune -a -f

        export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_YOURS}
        r="${_YOU}/ffmpeg-yours"
        t="${_VER_YOURS}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}"
        t_opt="-t ${r}:${t}"
        if test "${_BUILDPACKDEPS_TAG}" = "${_BUILDPACKDEPS_TAG_FOR_LATEST}" && \
           test "${_FFMPEG_VERSION}" = "${_FFMPEG_VERSION_FOR_LATEST}" ; then
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
    done
done
