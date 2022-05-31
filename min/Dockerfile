#
ARG _BUILDPACKDEPS_TAG=${_BUILDPACKDEPS_TAG:-22.04}
FROM hhsprings/buildpack-deps-plus:latest-from-${_BUILDPACKDEPS_TAG}
ARG _FFMPEG_VERSION=${_FFMPEG_VERSION:-4.4.2}
ARG _PREFIX=/usr/local
ARG _FFMPEG_EXTRA_VERSION_SUFFIX=${_FFMPEG_EXTRA_VERSION_SUFFIX:-hhsprings0.1-min}
ARG __APT_Y="-yq --no-install-recommends"
#
WORKDIR /tmp/build

#
RUN apt-get update && \
    apt-get ${__APT_Y} upgrade

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
# I thought I'd include text-related things in this "small ffmpeg".
# It may be different from your way of thinking. Even so, instead
# of asking me to change my mind, create your own Docker image.
# The purpose of this project is not to provide off-the-shelf
# products, but to "provide a template for you to create ffmpeg
# for yourself".
#
# ----------------------------------------------------------
RUN apt-get install ${__APT_Y} libass-dev
RUN apt-get install ${__APT_Y} libfribidi-dev
RUN apt-get install ${__APT_Y} libfontconfig-dev
RUN apt-get install ${__APT_Y} libfreetype-dev

# download specific released version, not current snapshot via git.
ADD https://ffmpeg.org/releases/ffmpeg-${_FFMPEG_VERSION}.tar.xz .

RUN tar Jxvf ffmpeg-${_FFMPEG_VERSION}.tar.xz
ENV FFMPEG_SRCDIR=/tmp/build/ffmpeg-${_FFMPEG_VERSION}
WORKDIR ${FFMPEG_SRCDIR}

#
ENV LD_LIBRARY_PATH=${_PREFIX}/lib64:${_PREFIX}/lib:${LD_LIBRARY_PATH:-/usr/lib64:/usr/lib}
ENV PKG_CONFIG_PATH=${_PREFIX}/lib64/pkgconfig:${_PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig}

#
RUN sh configure \
    --extra-version=${_FFMPEG_EXTRA_VERSION_SUFFIX} \
    --disable-static \
    --enable-shared \
    --enable-pthreads \
    \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfontconfig \
    --enable-libfreetype \
    \
    --disable-ffplay \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages

RUN make -j $(grep "^core id" /proc/cpuinfo | wc -l)
RUN make install
