#! /bin/sh
export __dopush=$(test "z${1}" = "z--push" && echo 1)
export _YOU=${_YOU:-hhsprings}
export _VER_MIN=${_VER_MIN:-0.4}
export _BUILDPACKDEPS_TAG_FOR_LATEST=22.10
export _FFMPEG_VERSION_FOR_LATEST=4.4.2
cd min
trap 'rm -f __tagged' 0 1 2 3 15
for _FFMPEG_VERSION in 4.1.9 4.2.7 4.3.4 4.4.2 ; do
    for _BUILDPACKDEPS_TAG in \
        stretch sid buster bullseye bookworm \
        16.04 18.04 20.04 21.10 22.04 22.10 ; do

        echo > __tagged
        export _FFMPEG_EXTRA_VERSION_SUFFIX=${_YOU}${_VER_MIN}-min
        #
        if (docker run -t \
                   ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} \
                   ffmpeg -version 2>&1) ; then
            docker rmi ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} > /dev/null || true
        else
            docker build -f Dockerfile -t ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} \
                   --build-arg _BUILDPACKDEPS_TAG=${_BUILDPACKDEPS_TAG} \
                   --build-arg _FFMPEG_VERSION=${_FFMPEG_VERSION} \
                   --build-arg _FFMPEG_EXTRA_VERSION_SUFFIX=${_FFMPEG_EXTRA_VERSION_SUFFIX} \
                   . || exit $?
            docker tag \
                   ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} \
                   ${_YOU}/ffmpeg-yours-min:latest-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}
            echo ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} >> __tagged
            echo ${_YOU}/ffmpeg-yours-min:latest-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} >> __tagged
            if test "z${__dopush}" = "z1" ; then
                (docker push ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} && \
                     docker push ${_YOU}/ffmpeg-yours-min:latest-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}) || exit $?
            fi
            if test "${_BUILDPACKDEPS_TAG}" = "${_BUILDPACKDEPS_TAG_FOR_LATEST}" -a \
                    ${_FFMPEG_VERSION} = "{_FFMPEG_VERSION_FOR_LATEST}" ; then
                docker tag \
                       ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} \
                       ${_YOU}/ffmpeg-yours-min:latest
                echo ${_YOU}/ffmpeg-yours-min:latest >> __tagged
                if test "z${__dopush}" = "z1" ; then
                    docker push ${_YOU}/ffmpeg-yours-min:latest || exit $?
                fi
            fi
            if test $? -eq 0 ; then
                docker run -t --rm ${_YOU}/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} ffmpeg -version
                for t in `cat __tagged` ; do
                    docker rmi ${t} > /dev/null || true
                done
            fi
        fi
    done
done
