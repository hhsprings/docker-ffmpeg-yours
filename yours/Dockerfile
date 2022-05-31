#
ARG _BUILDPACKDEPS_TAG=${_BUILDPACKDEPS_TAG:-22.04}
ARG _FFMPEG_VERSION=${_FFMPEG_VERSION:-4.4.2}
ARG _VER_MIN=${_VER_MIN:-0.1}
FROM hhsprings/ffmpeg-yours-min:${_VER_MIN}-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}
ARG _OPENCV_VERSION=${_OPENCV_VERSION:-3.4.15}
ARG _PREFIX=/usr/local
ARG _FFMPEG_EXTRA_VERSION_SUFFIX=${_FFMPEG_EXTRA_VERSION_SUFFIX:-hhsprings0.1}
ARG __APT_Y="-yq --no-install-recommends"
#
RUN apt-get update && \
    apt-get ${__APT_Y} upgrade

# ----------------------------------------------------------
#
# build opencv from source, because libopencv-dev of apt
# is broken or at least CRAZY in my humble opinion.
#
# ----------------------------------------------------------
# opencv from source
RUN apt-get install ${__APT_Y} libgtk2.0-dev

WORKDIR /tmp/build
# download specific released version, not current snapshot via git.
ADD https://github.com/opencv/opencv/archive/refs/tags/${_OPENCV_VERSION}.tar.gz .

RUN tar zxvf ${_OPENCV_VERSION}.tar.gz
ENV OPENCV_SRCDIR=/tmp/build/opencv-${_OPENCV_VERSION}
WORKDIR ${OPENCV_SRCDIR}
RUN mkdir build
WORKDIR ${OPENCV_SRCDIR}/build
# "-D OPENCV_GENERATE_PKGCONFIG=ON" has no effect if opencv 3.x, this is only for opencv 4+.
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE -D OPENCV_GENERATE_PKGCONFIG=ON -D CMAKE_INSTALL_PREFIX=${_PREFIX} ..
RUN make -j $(grep "^core id" /proc/cpuinfo | wc -l)
RUN make install

# ----------------------------------------------------------
#
# prepare dependancies which we can get with apt-get
# for full-build of ffmpeg
#
# ----------------------------------------------------------
#
RUN apt-get install ${__APT_Y} libssh-dev
RUN apt-get install ${__APT_Y} libgnutls28-dev
RUN apt-get install ${__APT_Y} nvidia-opencl-dev

#
RUN apt-get install ${__APT_Y} libsrt-gnutls-dev

#
RUN apt-get install ${__APT_Y} libx264-dev
RUN apt-get install ${__APT_Y} libx265-dev
RUN apt-get install ${__APT_Y} libvpx-dev
RUN apt-get install ${__APT_Y} libaom-dev
RUN apt-get install ${__APT_Y} libmp3lame-dev
RUN apt-get install ${__APT_Y} libtwolame-dev
RUN apt-get install ${__APT_Y} libopus-dev
RUN apt-get install ${__APT_Y} libvorbis-dev

#
RUN apt-get install ${__APT_Y} libbs2b-dev
RUN apt-get install ${__APT_Y} frei0r-plugins-dev
RUN apt-get install ${__APT_Y} libtesseract-dev libleptonica-dev tesseract-ocr-eng
RUN apt-get install ${__APT_Y} flite1-dev
RUN apt-get install ${__APT_Y} libchromaprint-dev
RUN apt-get install ${__APT_Y} librubberband-dev
RUN apt-get install ${__APT_Y} libzmq5-dev
RUN apt-get install ${__APT_Y} libzimg-dev
RUN apt-get install ${__APT_Y} libsoxr-dev
RUN apt-get install ${__APT_Y} libtheora-dev
RUN apt-get install ${__APT_Y} libmysofa-dev
RUN apt-get install ${__APT_Y} libshine-dev
RUN apt-get install ${__APT_Y} ladspa-sdk
RUN apt-get install ${__APT_Y} libspeex-dev
RUN apt-get install ${__APT_Y} libgme-dev
RUN apt-get install ${__APT_Y} libgsm1-dev
RUN apt-get install ${__APT_Y} libopenmpt-dev
RUN apt-get install ${__APT_Y} libmodplug-dev
RUN apt-get install ${__APT_Y} libopencore-amrwb-dev
RUN apt-get install ${__APT_Y} libopencore-amrnb-dev
RUN apt-get install ${__APT_Y} libvo-amrwbenc-dev
RUN apt-get install ${__APT_Y} libvulkan-dev
RUN apt-get install ${__APT_Y} glslang-dev
RUN apt-get install ${__APT_Y} libmfx-dev
RUN apt-get install ${__APT_Y} libvidstab-dev
RUN apt-get install ${__APT_Y} libxvidcore-dev
RUN apt-get install ${__APT_Y} libsvtav1enc-dev
RUN apt-get install ${__APT_Y} libzvbi-dev
RUN apt-get install ${__APT_Y} libdav1d-dev
RUN apt-get install ${__APT_Y} libcaca-dev
RUN apt-get install ${__APT_Y} libbluray-dev
RUN apt-get install ${__APT_Y} libsnappy-dev
RUN apt-get install ${__APT_Y} libgmp-dev
RUN apt-get install ${__APT_Y} libpulse-dev
RUN apt-get install ${__APT_Y} libpocketsphinx-dev
RUN apt-get install ${__APT_Y} pocketsphinx-en-us
RUN apt-get install ${__APT_Y} libdrm-dev
RUN apt-get install ${__APT_Y} librtmp-dev
RUN apt-get install ${__APT_Y} libxavs2-dev
RUN apt-get install ${__APT_Y} liblilv-dev

# ----------------------------------------------------------
#
# finally, full-build of ffmpeg.
#
# ----------------------------------------------------------
WORKDIR ${FFMPEG_SRCDIR}

RUN sh `head -1 ffbuild/config.log | sed 's@^# @@' | \
        sed "s@--extra-version=[^\s][^\s]*@--extra-version=${_FFMPEG_EXTRA_VERSION_SUFFIX}@"` \
    --enable-gpl \
    --enable-version3 \
    \
    --enable-lzma --enable-zlib --enable-iconv \
    \
    --enable-libsrt \
    \
    --enable-libssh \
    --enable-gnutls \
    \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libaom \
    --enable-libmp3lame \
    --enable-libtwolame \
    --enable-libopus \
    --enable-libvorbis \
    \
    --enable-libbs2b \
    --enable-frei0r \
    --enable-libflite \
    --enable-libtesseract \
    --enable-librubberband \
    --enable-chromaprint \
    --enable-libzmq \
    --enable-libzimg \
    --enable-libsoxr \
    --enable-libtheora \
    --enable-libmysofa \
    --enable-libshine \
    --enable-ladspa \
    --enable-libspeex \
    --enable-libopenjpeg \
    --enable-libgme \
    --enable-libgsm \
    --enable-libopenmpt \
    --enable-libmodplug \
    --enable-libopencore-amrwb \
    --enable-libopencore-amrnb \
    --enable-libvo-amrwbenc \
    --enable-vulkan \
    --enable-libglslang \
    --enable-libmfx \
    --enable-libvidstab \
    --enable-libxvid \
    --enable-libsvtav1 \
    --enable-libzvbi \
    --enable-libdav1d \
    --enable-libcaca \
    --enable-libbluray \
    --enable-libsnappy \
    --enable-gmp \
    --enable-libpulse \
    --enable-pocketsphinx \
    --enable-libdrm \
    --enable-librtmp \
    --enable-libxavs2 \
    --enable-lv2 \
    \
    --enable-opencl \
    --enable-libopencv

RUN make -j $(grep "^core id" /proc/cpuinfo | wc -l)
RUN make install
# -------------------------------------------------------
