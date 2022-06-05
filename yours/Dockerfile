#
ARG _BUILDPACKDEPS_TAG=22.04
ARG _FFMPEG_VERSION=4.4.2
FROM hhsprings/ffmpeg-yours-min:latest-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}
ARG _OPENCV_VERSION=3.4.15
ARG _PREFIX=/usr/local
ARG _FFMPEG_EXTRA_VERSION_SUFFIX=hhsprings0.1
ARG __APT_Y="-yq --no-install-recommends"
#
RUN apt-get update && \
    apt-get ${__APT_Y} upgrade

#
RUN touch ${FFMPEG_SRCDIR}/_enable_if_available

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

RUN tar zxvf ${_OPENCV_VERSION}.tar.gz && rm -fv ${_OPENCV_VERSION}.tar.gz
ENV OPENCV_SRCDIR=/tmp/build/opencv-${_OPENCV_VERSION}
WORKDIR ${OPENCV_SRCDIR}
RUN mkdir build
WORKDIR ${OPENCV_SRCDIR}/build
# "-D OPENCV_GENERATE_PKGCONFIG=ON" has no effect if opencv 3.x, this is only for opencv 4+.
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D BUILD_TESTS=OFF \
    -D CMAKE_INSTALL_PREFIX=${_PREFIX} \
    ..
RUN make -j $(grep "^core id" /proc/cpuinfo | wc -l)
RUN make install
RUN echo --enable-libopencv >> ${FFMPEG_SRCDIR}/_enable_if_available
    
# ----------------------------------------------------------
#
# prepare dependancies which we can get with apt-get
# for full-build of ffmpeg
#
# ----------------------------------------------------------
#
RUN apt-get install ${__APT_Y} libssh-dev
RUN apt-get install ${__APT_Y} libgnutls28-dev
RUN (\
     if apt-get install ${__APT_Y} ocl-icd-opencl-dev ; then \
         echo --enable-opencl >> ${FFMPEG_SRCDIR}/_enable_if_available ; \
     fi) || true
RUN (\
     if apt-get install ${__APT_Y} nvidia-opencl-dev ; then \
         grep opencl ${FFMPEG_SRCDIR}/_enable_if_available${FFMPEG_SRCDIR}/_enable_if_available || \
             echo --enable-opencl >> ${FFMPEG_SRCDIR}/_enable_if_available ; \
     fi) || true

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
# frei0r-plugins-dev don't install /usr/lib/frei0r-1 files.
RUN apt-get install ${__APT_Y} frei0r-plugins
ENV FREI0R_PATH=/usr/lib/frei0r-1

RUN apt-get install ${__APT_Y} libtesseract-dev libleptonica-dev tesseract-ocr-eng
RUN apt-get install ${__APT_Y} flite1-dev
RUN apt-get install ${__APT_Y} libchromaprint-dev
RUN apt-get install ${__APT_Y} librubberband-dev
RUN apt-get install ${__APT_Y} libzmq5-dev
RUN (\
     if apt-get install ${__APT_Y} libzimg-dev ; then \
         echo --enable-libzimg >> ${FFMPEG_SRCDIR}/_enable_if_available ; \
     fi) || true
RUN apt-get install ${__APT_Y} libsoxr-dev
RUN apt-get install ${__APT_Y} libtheora-dev
RUN apt-get install ${__APT_Y} libmysofa-dev
RUN apt-get install ${__APT_Y} libshine-dev

#
RUN apt-get install ${__APT_Y} ladspa-sdk
# The LADSPA plug-in that follows is not essential, so simply ignore the error.
RUN apt-get install ${__APT_Y} csladspa || true
RUN apt-get install ${__APT_Y} bs2b-ladspa || true
RUN apt-get install ${__APT_Y} guitarix-ladspa || true
RUN apt-get install ${__APT_Y} invada-studio-plugins-ladspa || true
RUN apt-get install ${__APT_Y} rubberband-ladspa || true
# Environment variable for /usr/bin/listplugins, etc.
ENV LADSPA_PATH=/usr/lib/ladspa

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
RUN (\
     if apt-get install ${__APT_Y} libsvtav1enc-dev ; then \
         echo --enable-libsvtav1 >> ${FFMPEG_SRCDIR}/_enable_if_available ; \
     fi) || true
RUN apt-get install ${__APT_Y} libzvbi-dev
RUN apt-get install ${__APT_Y} libcaca-dev
RUN apt-get install ${__APT_Y} libbluray-dev
RUN apt-get install ${__APT_Y} libsnappy-dev
RUN apt-get install ${__APT_Y} libgmp-dev
RUN apt-get install ${__APT_Y} libpulse-dev
RUN apt-get install ${__APT_Y} libpocketsphinx-dev
RUN apt-get install ${__APT_Y} pocketsphinx-en-us
RUN apt-get install ${__APT_Y} libdrm-dev
RUN apt-get install ${__APT_Y} librtmp-dev
RUN (\
     if apt-get install ${__APT_Y} libxavs2-dev ; then \
         echo --enable-libxavs2 >> ${FFMPEG_SRCDIR}/_enable_if_available ; \
     fi) || true
RUN apt-get install ${__APT_Y} liblilv-dev
RUN apt-get install ${__APT_Y} librsvg2-dev
RUN apt-get install ${__APT_Y} libcodec2-dev
RUN apt-get install ${__APT_Y} libsmbclient-dev
RUN (\
     if apt-get install ${__APT_Y} librist-dev ; then \
         echo --enable-librist >> ${FFMPEG_SRCDIR}/_enable_if_available ; \
     fi) || true
RUN (\
     if apt-get install ${__APT_Y} libdav1d-dev ; then \
         echo --enable-libdav1d >> ${FFMPEG_SRCDIR}/_enable_if_available ; \
     fi) || true
RUN (\
     if apt-get install ${__APT_Y} libopenh264-dev ; then \
         echo --enable-libopenh264 >> ${FFMPEG_SRCDIR}/_enable_if_available ; \
     fi) || true

# ----------------------------------------------------------
#
# finally, full-build of ffmpeg.
#
# ----------------------------------------------------------
WORKDIR ${FFMPEG_SRCDIR}

RUN sh `head -1 ffbuild/config.log | sed 's@^# @@' | \
        sed "s@--extra-version=[^ ][^ ]* @--extra-version=${_FFMPEG_EXTRA_VERSION_SUFFIX} @"` \
    --enable-gpl \
    --enable-version3 \
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
    --enable-libzvbi \
    --enable-libcaca \
    --enable-libbluray \
    --enable-libsnappy \
    --enable-gmp \
    --enable-libpulse \
    --enable-pocketsphinx \
    --enable-libdrm \
    --enable-librtmp \
    --enable-lv2 \
    --enable-librsvg \
    --enable-libcodec2 \
    --enable-libsmbclient \
    $(cat _enable_if_available)

RUN make -j $(grep "^core id" /proc/cpuinfo | wc -l)
RUN make install
# -------------------------------------------------------

# ----------------------------------------------------------
#
# Cleanup apt-related.
# It was intended not to erase the traces of my own build.
# (This is so that the container inherited by FROM can use
# it as it is.)
#
# ----------------------------------------------------------
RUN rm -rf /var/lib/apt/lists/*
