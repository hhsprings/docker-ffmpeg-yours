#! /bin/sh
export __push=$(if test "z${1:-''}" = "z--push" ; then echo true ; else echo false ; fi)
export _YOU=${_YOU:-hhsprings}
export _VER_YOURS=0.8.5
export _BUILDPACKDEPS_TAG_FOR_LATEST=22.10
export _FFMPEG_VERSION=4.4.2
export _OPENCV_VERSION=3.4.15

cd yours
for _BUILDPACKDEPS_TAG in 22.10 22.04 ; do

    export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_YOURS}
    r="${_YOU}/ffmpeg-yours"
    t="${_VER_YOURS}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}"
    t_opt="-t ${r}:${t}"
    if test "${_BUILDPACKDEPS_TAG}" = "${_BUILDPACKDEPS_TAG_FOR_LATEST}" ; then
        t_opt="${t_opt} -t ${r}:latest"
    fi
    docker buildx build -f Dockerfile \
           ${t_opt} \
           --build-arg _BUILDPACKDEPS_TAG=${_BUILDPACKDEPS_TAG} \
           --build-arg _FFMPEG_VERSION=${_FFMPEG_VERSION} \
           --build-arg _OPENCV_VERSION=${_OPENCV_VERSION} \
           --build-arg _FFMPEG_EXTRA_VERSION_SUFFIX=${_FFMPEG_EXTRA_VERSION_SUFFIX} \
           --platform linux/amd64 \
           -o type=image,push=${__push} \
           . || exit $?
    if test $? -eq 0 && test ${__push} = "true" ; then
        docker run -t --rm ${r}:${t} ffmpeg -version
    fi
done
