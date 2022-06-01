#! /bin/sh
export _YOU=${_YOU:-hhsprings}
export _VER_MIN=0.2
export _VER_YOURS=0.2
export _BUILDPACKDEPS_TAG=22.10
export _FFMPEG_VERSION=4.4.2
export _OPENCV_VERSION=3.4.15
(
    export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_MIN}-min
    cd min
    docker build -f Dockerfile -t ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} \
           --build-arg _BUILDPACKDEPS_TAG=${_BUILDPACKDEPS_TAG} \
           --build-arg _FFMPEG_VERSION=${_FFMPEG_VERSION} \
           --build-arg _FFMPEG_EXTRA_VERSION_SUFFIX=${_FFMPEG_EXTRA_VERSION_SUFFIX} \
           .
    docker tag \
           ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} \
           ${_YOU}/ffmpeg-yours-min:latest-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}
    docker tag \
           ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} \
           ${_YOU}/ffmpeg-yours-min:latest
) && \
(
    export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_YOURS}
    cd yours
    docker build -f Dockerfile -t ${_YOU}/ffmpeg-yours:${_VER_YOURS}-${_FFMPEG_VERSION}-${_OPENCV_VERSION}-${_BUILDPACKDEPS_TAG} \
           --build-arg _BUILDPACKDEPS_TAG=${_BUILDPACKDEPS_TAG} \
           --build-arg _FFMPEG_VERSION=${_FFMPEG_VERSION} \
           --build-arg _OPENCV_VERSION=${_OPENCV_VERSION} \
           --build-arg _FFMPEG_EXTRA_VERSION_SUFFIX=${_FFMPEG_EXTRA_VERSION_SUFFIX} \
           .
    docker tag \
           ${_YOU}/ffmpeg-yours:${_VER_YOURS}-${_FFMPEG_VERSION}-${_OPENCV_VERSION}-${_BUILDPACKDEPS_TAG} \
           ${_YOU}/ffmpeg-yours:latest
)
