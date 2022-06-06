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
WORKDIR /tmp/build
COPY _apt_install.sh /tmp/build
RUN chmod u+x /tmp/build/_apt_install.sh

# ----------------------------------------------------------
#
# build opencv from source, because libopencv-dev of apt
# is broken or at least CRAZY in my humble opinion.
#
# ----------------------------------------------------------
# opencv from source
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libgtk2.0-dev "" ""

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
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libssh-dev "" --enable-libssh
RUN apt-get install ${__APT_Y} libgnutls28-dev
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} ocl-icd-opencl-dev "" --enable-opencl
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} nvidia-opencl-dev "" --enable-opencl

#
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libsrt-gnutls-dev "" --enable-libsrt

#
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libx264-dev "" --enable-libx264
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libx265-dev "" --enable-libx265
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libvpx-dev "" --enable-libvpx
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libwebp-dev "" --enable-libwebp
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libaom-dev "" --enable-libaom
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libmp3lame-dev "" --enable-libmp3lame
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libtwolame-dev "" --enable-libtwolame
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libopus-dev "" --enable-libopus
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libvorbis-dev "" --enable-libvorbis

#
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libbs2b-dev "" --enable-libbs2b
# frei0r-plugins-dev don't install /usr/lib/frei0r-1 files.
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} "frei0r-plugins-dev frei0r-plugins" "" --enable-frei0r
ENV FREI0R_PATH=/usr/lib/frei0r-1

RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} \
    "libtesseract-dev libleptonica-dev tesseract-ocr-eng" "" --enable-libtesseract

RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} flite1-dev "" --enable-libflite
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libchromaprint-dev "" --enable-chromaprint

RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} librubberband-dev "" --enable-librubberband

RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libzmq5-dev "" --enable-libzmq
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libzimg-dev "" --enable-libzimg
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libsoxr-dev "" --enable-libsoxr
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libtheora-dev "" --enable-libtheora
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libmysofa-dev "" --enable-libmysofa
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libshine-dev "" --enable-libshine

#
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} ladspa-sdk "" --enable-ladspa
# The LADSPA plug-in that follows is not essential, so simply ignore the error.
RUN apt-get install ${__APT_Y} csladspa || true
RUN apt-get install ${__APT_Y} bs2b-ladspa || true
RUN apt-get install ${__APT_Y} guitarix-ladspa || true
RUN apt-get install ${__APT_Y} invada-studio-plugins-ladspa || true
RUN apt-get install ${__APT_Y} rubberband-ladspa || true
# Environment variable for /usr/bin/listplugins, etc.
ENV LADSPA_PATH=/usr/lib/ladspa

RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libspeex-dev "" --enable-libspeex
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libgme-dev "" --enable-libgme

RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libgsm1-dev "" --enable-libgsm
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libopenmpt-dev "" --enable-libopenmpt
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libmodplug-dev "" --enable-libmodplug
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libopencore-amrwb-dev "" --enable-libopencore-amrwb
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libopencore-amrnb-dev "" --enable-libopencore-amrnb
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libvo-amrwbenc-dev "" --enable-libvo-amrwbenc
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libvulkan-dev "" --enable-vulkan
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} glslang-dev "" --enable-libglslang
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libmfx-dev "" --enable-libmfx
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libvidstab-dev "" --enable-libvidstab
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libxvidcore-dev "" --enable-libxvid
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libsvtav1enc-dev "" --enable-libsvtav1
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libzvbi-dev "" --enable-libzvbi
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libcaca-dev "" --enable-libcaca
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libbluray-dev "" --enable-libbluray
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libsnappy-dev "" --enable-libsnappy
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libgmp-dev "" --enable-gmp
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libpulse-dev "" --enable-libpulse
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} \
    "libpocketsphinx-dev pocketsphinx-en-us" "" --enable-pocketsphinx
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libdrm-dev "" --enable-libdrm
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} librtmp-dev "" --enable-librtmp
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libxavs2-dev "" --enable-libxavs2
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} "liblilv-dev lilv-utils" "" --enable-lv2
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} librsvg2-dev "" --enable-librsvg
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libcodec2-dev "" --enable-libcodec2
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libsmbclient-dev "" --enable-libsmbclient
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} librist-dev "" --enable-librist
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libdav1d-dev "" --enable-libdav1d
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} libopenh264-dev "" --enable-libopenh264
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} librabbitmq-dev "" --enable-librabbitmq
RUN /tmp/build/_apt_install.sh ${FFMPEG_SRCDIR} "libdc1394-dev libraw1394-dev" "" --enable-libdc1394

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
    --enable-gnutls \
    \
    --enable-libopenjpeg \
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
