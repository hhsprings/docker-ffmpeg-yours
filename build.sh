#! /bin/sh
export _YOU=${_YOU:-hhsprings}
export _VER_MIN=0.1
export _VER_YOURS=0.1
export _BUILDPACKDEPS_TAG=22.04
export _FFMPEG_VERSION=4.4.2
export _OPENCV_VERSION=3.4.15
(
    export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_MIN}-min
    cd min
    docker build -f Dockerfile -t ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} .
) && \
(
    export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_YOURS}
    cd yours
    docker build -f Dockerfile -t ${_YOU}/ffmpeg-yours:${_VER_YOURS}-${_FFMPEG_VERSION}-${_OPENCV_VERSION}-${_BUILDPACKDEPS_TAG} .
)
