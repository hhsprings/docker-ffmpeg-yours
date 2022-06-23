#
ARG _BUILDPACKDEPS_TAG=22.04
FROM hhsprings/buildpack-deps-plus:latest-from-${_BUILDPACKDEPS_TAG}
ARG _FFMPEG_VERSION=4.4.2
ARG _PREFIX=/usr/local
ARG _FFMPEG_EXTRA_VERSION_SUFFIX=hhsprings0.1-min
ARG __APT_Y="-yq --no-install-recommends"

#
RUN apt-get -q update && \
    apt-get ${__APT_Y} upgrade

#
WORKDIR /tmp/build
RUN touch /tmp/build/_enable_if_available
COPY _apt_install.sh /tmp/build
RUN chmod u+x /tmp/build/_apt_install.sh

# ----------------------------------------------------------
#
# For example, ffmpeg and opencv are interdependent with each
# other. Therefore, install the small ffmpeg in advance.
# BTW, latest ffmpeg will not build libavresample, so
# if you want to it for some reasons, specify --enable-avresample
# to "configure".
#
# The definition of "small ffmpeg" will vary from person to
# person. If you think of it as minimal, you may want to avoid
# explicit dependencies on third-party modules. However, it is
# better to consider the overall balance, including the problem
# of image build time.
#
# I thought I'd include text-related things (and some extra)
# in this "small ffmpeg". It may be different from your way of
# thinking. Even so, instead of asking me to change my mind, create
# your own Docker image. The purpose of this project is not to provide
# off-the-shelf products, but to "provide a template for you to create
# ffmpeg for yourself".
#
# I decided to include "caca" and not "ffplay". The point of view of
# this is "Do you think about using it only in the docker environment,
# or do you think about using it outside the docker box?" The drawback
# is that "caca" depends on third-party modules. However, it is very
# convenient to visually check the video (even at rough resolutions)
# when living only in docker. On the other hand, although ffplay is
# the original distribution of FFMPEG, it is an application that is
# not easy to run only in the docker environment. In my "configre"
# I explicitly "--disable-ffplay", but in the first place, building
# ffplay depends on a special set of packages that is different from
# ffmpeg. The dependent module installation described in this Dockerfile
# alone does not meet the conditions for building ffplay (so
# "--enable-ffplay" is invalid). For example, if you install "libsdl2-dev",
# ffplay will be the build target. It's up to you to extract the
# resulting FFMPEG environment out of the Docker box. In that case,
# if you want to build ffplay as well, do so.
#
# By the way, I have specified some auto-discovered options (lzma,
# zlib, etc.) for clarity. Setting "--enable-" for something that
# is detected as "available" by auto-discovery has no effect on
# the execution of the final FFMPEG other than the banner output.
# ----------------------------------------------------------
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" zlib1g-dev "" --enable-zlib && \
     /tmp/build/_apt_install.sh "ffmpeg" liblzma-dev "" --enable-lzma && \
     /tmp/build/_apt_install.sh "ffmpeg" libxml2-dev "" --enable-libxml2 && \
     /tmp/build/_apt_install.sh "ffmpeg" libass-dev "" --enable-libass && \
     /tmp/build/_apt_install.sh "ffmpeg" libfribidi-dev "" --enable-libfribidi && \
     /tmp/build/_apt_install.sh "ffmpeg" libfontconfig-dev libfontconfig1-dev --enable-libfontconfig && \
     /tmp/build/_apt_install.sh "ffmpeg" libfreetype-dev libfreetype6-dev --enable-libfreetype && \
     /tmp/build/_apt_install.sh "ffmpeg" libopenjp2-7-dev "" --enable-libopenjpeg && \
     /tmp/build/_apt_install.sh "ffmpeg" libcaca-dev "" --enable-libcaca \
    )

# download specific released version, not current snapshot via git.
ADD https://ffmpeg.org/releases/ffmpeg-${_FFMPEG_VERSION}.tar.xz .

RUN tar Jxf ffmpeg-${_FFMPEG_VERSION}.tar.xz && rm -fv ffmpeg-${_FFMPEG_VERSION}.tar.xz
ENV FFMPEG_SRCDIR=/tmp/build/ffmpeg-${_FFMPEG_VERSION}
WORKDIR ${FFMPEG_SRCDIR}

#
ENV LD_LIBRARY_PATH=${_PREFIX}/lib64:${_PREFIX}/lib:${LD_LIBRARY_PATH:-/usr/lib/x86_64-linux-gnu:/usr/lib64:/usr/lib}
ENV PKG_CONFIG_PATH=${_PREFIX}/lib64/pkgconfig:${_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig}

#
RUN sh configure \
    --extra-version=${_FFMPEG_EXTRA_VERSION_SUFFIX} \
    --disable-static \
    --enable-shared \
    --enable-pthreads \
    --disable-debug \
    \
    --enable-iconv \
    \
    $(grep "^ffmpeg:" /tmp/build/_enable_if_available | sed 's@^ffmpeg:@@') \
    \
    --disable-ffplay \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages && \
    make -j $(grep "^core id" /proc/cpuinfo | wc -l) && make install

# ----------------------------------------------------------
#
# Cleanup apt-related.
# It was intended not to erase the traces of my own build.
# (This is so that the container inherited by FROM can use
# it as it is.)
#
# ----------------------------------------------------------
RUN rm -rf /var/lib/apt/lists/*
