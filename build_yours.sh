#! /bin/sh
export __dopush=$(test "z${1}" = "z--push" && echo 1)
export _YOU=${_YOU:-hhsprings}
export _VER_YOURS=0.4
export _BUILDPACKDEPS_TAG_FOR_LATEST=22.10
export _FFMPEG_VERSION=4.4.2
export _OPENCV_VERSION=3.4.15
cd yours
for _BUILDPACKDEPS_TAG in 22.04 22.10 ; do

    export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_YOURS}
    docker build -f Dockerfile -t ${_YOU}/ffmpeg-yours:${_VER_YOURS}-${_FFMPEG_VERSION}-${_OPENCV_VERSION}-${_BUILDPACKDEPS_TAG} \
           --build-arg _BUILDPACKDEPS_TAG=${_BUILDPACKDEPS_TAG} \
           --build-arg _FFMPEG_VERSION=${_FFMPEG_VERSION} \
           --build-arg _OPENCV_VERSION=${_OPENCV_VERSION} \
           --build-arg _FFMPEG_EXTRA_VERSION_SUFFIX=${_FFMPEG_EXTRA_VERSION_SUFFIX} \
           . || exit $?
    if test "z${__dopush}" = "z1" ; then
        docker push ${_YOU}/ffmpeg-yours:${_VER_YOURS}-${_FFMPEG_VERSION}-${_OPENCV_VERSION}-${_BUILDPACKDEPS_TAG} || exit $?
    fi
    if test "${_BUILDPACKDEPS_TAG}" = "${_BUILDPACKDEPS_TAG_FOR_LATEST}" ; then
        docker tag \
               ${_YOU}/ffmpeg-yours:${_VER_YOURS}-${_FFMPEG_VERSION}-${_OPENCV_VERSION}-${_BUILDPACKDEPS_TAG} \
               ${_YOU}/ffmpeg-yours:latest
        if test "z${__dopush}" = "z1" ; then
            docker push ${_YOU}/ffmpeg-yours:latest || exit $?
        fi
    fi
    if test $? -eq 0 ; then
        docker run -it --rm ${_YOU}/ffmpeg-yours:${_VER_YOURS}-${_FFMPEG_VERSION}-${_OPENCV_VERSION}-${_BUILDPACKDEPS_TAG} ffmpeg -version
    fi
done
