#
ARG _BUILDPACKDEPS_TAG=22.10
ARG _FFMPEG_VERSION=4.4.2

# ----------------------------------------------------------
#
# build librav1e, and liblensfun from source, because the version
# of these managed by apt does not match the version expected by
# ffmpeg to be built.
# 
# Since librav1e is written by the "RUST language", we need a
# "RUST compiler" to build it, but the resulting librav1e does
# not depend on "something like RUST runtimes". So, I will
# build librav1e in another environment and copy only the binary.
#
# Although liblensfun itself has no special dependencies, the
# version selection that ffmpeg expects is strange. If these special
# circumstances pollute the ffmpeg build environment of the main
# subject, it will be difficult to manage, so I will treat this
# as well as librav1e.
#
# ----------------------------------------------------------
FROM hhsprings/buildpack-deps-plus:latest-from-${_BUILDPACKDEPS_TAG} AS librav1e_build
ARG _LIBRAV1E_VERSION=0.5.1
RUN apt-get -q update

# librav1e
RUN apt-get install -yq --no-install-recommends cargo nasm
WORKDIR /tmp/build
ADD https://github.com/xiph/rav1e/archive/refs/tags/v${_LIBRAV1E_VERSION}.tar.gz .
RUN tar zxf v${_LIBRAV1E_VERSION}.tar.gz && rm -f v${_LIBRAV1E_VERSION}.tar.gz
WORKDIR /tmp/build/rav1e-${_LIBRAV1E_VERSION}
# OK on ubuntu:kinetic / NG on ubuntu:jammy
RUN (cargo install cargo-c && cargo cinstall --release) || true

# liblensfun
WORKDIR /tmp/build
ARG _LIBLENSFUN_SSVERSION=5604b519fd0ea553655473dee359ee0b4bd0b11b
ADD https://github.com/lensfun/lensfun/archive/${_LIBLENSFUN_SSVERSION}.zip .
RUN unzip ${_LIBLENSFUN_SSVERSION}.zip && rm -f v${_LIBLENSFUN_SSVERSION}.zip
WORKDIR /tmp/build/lensfun-${_LIBLENSFUN_SSVERSION}
RUN (\
     mkdir build ; cd build ; \
     cmake -D CMAKE_BUILD_TYPE=Release .. && \
         make -j $(grep "^core id" /proc/cpuinfo | wc -l) && \
         make install) || true

# ----------------------------------------------------------
#
# The main subject ffmpeg build environment.
#
# ----------------------------------------------------------
FROM hhsprings/ffmpeg-yours-min:latest-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG}
ARG _OPENCV_VERSION=3.4.15
ARG _PREFIX=/usr/local
ARG _FFMPEG_EXTRA_VERSION_SUFFIX=hhsprings0.1
ARG _AVISYNTHPLUS_VERSION=3.7.2
#
RUN apt-get -q update && apt-get -yq --no-install-recommends upgrade
COPY --from=librav1e_build /usr/local /usr/local
RUN (\
     if test -f /usr/local/lib/pkgconfig/rav1e.pc ; then \
         echo ffmpeg:--enable-librav1e >> /tmp/build/_enable_if_available ; \
     else true ; fi)
RUN (\
     if test -f /usr/local/lib/pkgconfig/lensfun.pc ; then \
         echo ffmpeg:--enable-liblensfun >> /tmp/build/_enable_if_available ; \
     else true ; fi)
#
WORKDIR /tmp/build

# ----------------------------------------------------------
#
# build opencv from source, because libopencv-dev of apt
# is broken or at least CRAZY in my humble opinion.
#
# ----------------------------------------------------------
# opencv from source
RUN /tmp/build/_apt_install.sh "ffmpeg" libgtk2.0-dev "" ""

# download specific released version, not current snapshot via git.
ADD https://github.com/opencv/opencv/archive/refs/tags/${_OPENCV_VERSION}.tar.gz .

RUN tar zxf ${_OPENCV_VERSION}.tar.gz && rm -fv ${_OPENCV_VERSION}.tar.gz
ENV OPENCV_SRCDIR=/tmp/build/opencv-${_OPENCV_VERSION}
WORKDIR ${OPENCV_SRCDIR}/build
# "-D OPENCV_GENERATE_PKGCONFIG=ON" has no effect if opencv 3.x, this is only for opencv 4+.
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_SHARED_LIBS=ON \
    -D ENABLE_PIC=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D BUILD_TESTS=OFF \
    -D CMAKE_INSTALL_PREFIX=${_PREFIX} \
    .. && \
    make -j $(grep "^core id" /proc/cpuinfo | wc -l) && make install && \
    echo ffmpeg:--enable-libopencv >> /tmp/build/_enable_if_available

# ----------------------------------------------------------
#
# prepare dependancies which we can get with apt-get
# for full-build of ffmpeg
#
# ----------------------------------------------------------
#
# I excluded the ffplay build with "-min", but I want to target it here.
# The easiest way to do this is to install "libsdl2-dev". Installing
# "libsdl2-dev" not only affects "--enable-ffplay", but also involves
# "--enable-sdl2" as well as "--enable-sndio", "--enable-opengl". Also,
# although not documented, "libavdevice/xv.c" seems to depend on the presence
# or absence of "libxv1-dev", and the installation of "libsdl2-dev" enables
# the build of "libavdevice/xv.c" as a result (this allows you to use
# "-f xv"). It's actually hard to try to run them just inside the docker
# container, but some "ffmpeg-yours" users may "copy and use the built
# product". For those people, ffplay, sdl, and xv shouldn't be difficult
# to get them working. (Even if you are a Windows user, I think you can
# get it to work by extracting "/usr/local" from the docker container
# and replicating it to the WSL2 environment.)
RUN /tmp/build/_apt_install.sh "ffmpeg" libsdl2-dev "" "--enable-sdl2 --enable-sndio --enable-opengl"

#
#
RUN /tmp/build/_apt_install.sh "ffmpeg" libssh-dev "" --enable-libssh
RUN /tmp/build/_apt_install.sh "ffmpeg" libgnutls28-dev "" "--enable-gnutls"
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" ocl-icd-opencl-dev "" --enable-opencl ; \
     /tmp/build/_apt_install.sh "ffmpeg" nvidia-opencl-dev "" --enable-opencl \
    )

#
RUN /tmp/build/_apt_install.sh "ffmpeg" libsrt-gnutls-dev "" --enable-libsrt

#
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" libx264-dev "" --enable-libx264 ; \
     /tmp/build/_apt_install.sh "ffmpeg" libx265-dev "" --enable-libx265 ; \
     /tmp/build/_apt_install.sh "ffmpeg" libvpx-dev "" --enable-libvpx ; \
     /tmp/build/_apt_install.sh "ffmpeg" libwebp-dev "" --enable-libwebp ; \
     /tmp/build/_apt_install.sh "ffmpeg" libaom-dev "" --enable-libaom ; \
     /tmp/build/_apt_install.sh "ffmpeg" libtheora-dev "" --enable-libtheora ; \
     /tmp/build/_apt_install.sh "ffmpeg" libsvtav1enc-dev "" --enable-libsvtav1 ; \
     /tmp/build/_apt_install.sh "ffmpeg" libxvidcore-dev "" --enable-libxvid ; \
     /tmp/build/_apt_install.sh "ffmpeg" libxavs2-dev "" --enable-libxavs2 ; \
     /tmp/build/_apt_install.sh "ffmpeg" libmfx-dev "" --enable-libmfx ; \
     /tmp/build/_apt_install.sh "ffmpeg" libdav1d-dev "" --enable-libdav1d ; \
     /tmp/build/_apt_install.sh "ffmpeg" libopenh264-dev "" --enable-libopenh264 \
    )
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" libmp3lame-dev "" --enable-libmp3lame ; \
     /tmp/build/_apt_install.sh "ffmpeg" libtwolame-dev "" --enable-libtwolame ; \
     /tmp/build/_apt_install.sh "ffmpeg" libopus-dev "" --enable-libopus ; \
     /tmp/build/_apt_install.sh "ffmpeg" libvorbis-dev "" --enable-libvorbis ; \
     /tmp/build/_apt_install.sh "ffmpeg" libshine-dev "" --enable-libshine ; \
     /tmp/build/_apt_install.sh "ffmpeg" libspeex-dev "" --enable-libspeex ; \
     /tmp/build/_apt_install.sh "ffmpeg" libopencore-amrwb-dev "" --enable-libopencore-amrwb ; \
     /tmp/build/_apt_install.sh "ffmpeg" libopencore-amrnb-dev "" --enable-libopencore-amrnb ; \
     /tmp/build/_apt_install.sh "ffmpeg" libcodec2-dev "" --enable-libcodec2 \
    )

#
RUN /tmp/build/_apt_install.sh "ffmpeg" libbs2b-dev "" --enable-libbs2b
# frei0r-plugins-dev don't install /usr/lib/frei0r-1 files.
RUN /tmp/build/_apt_install.sh "ffmpeg" "frei0r-plugins-dev frei0r-plugins" "" --enable-frei0r
ENV FREI0R_PATH=/usr/lib/frei0r-1

RUN /tmp/build/_apt_install.sh "ffmpeg" \
    "libtesseract-dev libleptonica-dev tesseract-ocr-eng" "" --enable-libtesseract

RUN /tmp/build/_apt_install.sh "ffmpeg" flite1-dev "" --enable-libflite
RUN /tmp/build/_apt_install.sh "ffmpeg" libchromaprint-dev "" --enable-chromaprint

RUN /tmp/build/_apt_install.sh "ffmpeg" librubberband-dev "" --enable-librubberband

RUN /tmp/build/_apt_install.sh "ffmpeg" libzmq5-dev "" --enable-libzmq
RUN /tmp/build/_apt_install.sh "ffmpeg" libzimg-dev "" --enable-libzimg
RUN /tmp/build/_apt_install.sh "ffmpeg" libsoxr-dev "" --enable-libsoxr
RUN /tmp/build/_apt_install.sh "ffmpeg" libmysofa-dev "" --enable-libmysofa

#
RUN /tmp/build/_apt_install.sh "ffmpeg" ladspa-sdk "" --enable-ladspa
# The LADSPA plug-in that follows is not essential, so simply ignore the error.
RUN (\
     apt-get install ${__APT_Y} csladspa || true ; \
     apt-get install ${__APT_Y} bs2b-ladspa || true ; \
     apt-get install ${__APT_Y} guitarix-ladspa || true ; \
     apt-get install ${__APT_Y} invada-studio-plugins-ladspa || true ; \
     apt-get install ${__APT_Y} rubberband-ladspa || true \
    )
# Environment variable for /usr/bin/listplugins, etc.
ENV LADSPA_PATH=/usr/lib/ladspa

RUN /tmp/build/_apt_install.sh "ffmpeg" libgme-dev "" --enable-libgme

RUN /tmp/build/_apt_install.sh "ffmpeg" libgsm1-dev "" --enable-libgsm
RUN /tmp/build/_apt_install.sh "ffmpeg" libopenmpt-dev "" --enable-libopenmpt
RUN /tmp/build/_apt_install.sh "ffmpeg" libmodplug-dev "" --enable-libmodplug
RUN /tmp/build/_apt_install.sh "ffmpeg" libvo-amrwbenc-dev "" --enable-libvo-amrwbenc
RUN /tmp/build/_apt_install.sh "ffmpeg" libvulkan-dev "" --enable-vulkan
RUN /tmp/build/_apt_install.sh "ffmpeg" glslang-dev "" --enable-libglslang
RUN /tmp/build/_apt_install.sh "ffmpeg" libvidstab-dev "" --enable-libvidstab
RUN /tmp/build/_apt_install.sh "ffmpeg" libzvbi-dev "" --enable-libzvbi
RUN /tmp/build/_apt_install.sh "ffmpeg" libbluray-dev "" --enable-libbluray
RUN /tmp/build/_apt_install.sh "ffmpeg" libsnappy-dev "" --enable-libsnappy
RUN /tmp/build/_apt_install.sh "ffmpeg" libgmp-dev "" --enable-gmp
RUN /tmp/build/_apt_install.sh "ffmpeg" libpulse-dev "" --enable-libpulse
RUN /tmp/build/_apt_install.sh "ffmpeg" \
    "libpocketsphinx-dev pocketsphinx-en-us" "" --enable-pocketsphinx
RUN /tmp/build/_apt_install.sh "ffmpeg" libdrm-dev "" --enable-libdrm
RUN /tmp/build/_apt_install.sh "ffmpeg" librtmp-dev "" --enable-librtmp

# "Lv2 is dead"? When I visit a site that claims to be a LV2 project, I can't
# find any "/plugins"  available in this ffmpeg lv2 filter. So at least the
# information about "the lv2 plugin that ffmpeg  wants to use" is completely
# obsolete. At least, I couldn't find a workable example at all.
#RUN /tmp/build/_apt_install.sh "ffmpeg" "liblilv-dev lilv-utils" "" --enable-lv2

#
RUN /tmp/build/_apt_install.sh "ffmpeg" librsvg2-dev "" --enable-librsvg
RUN /tmp/build/_apt_install.sh "ffmpeg" libsmbclient-dev "" --enable-libsmbclient
RUN /tmp/build/_apt_install.sh "ffmpeg" librist-dev "" --enable-librist
RUN /tmp/build/_apt_install.sh "ffmpeg" librabbitmq-dev "" --enable-librabbitmq
RUN /tmp/build/_apt_install.sh "ffmpeg" "libdc1394-dev libraw1394-dev" "" --enable-libdc1394
RUN /tmp/build/_apt_install.sh "ffmpeg" libjack-dev "" --enable-libjack
RUN /tmp/build/_apt_install.sh "ffmpeg" libaribb24-dev "" --enable-libaribb24
RUN /tmp/build/_apt_install.sh "ffmpeg" "libomxil-bellagio-dev libomxil-bellagio-dev" "" "--enable-omx"

# ----------------------------------------------------------
#
# Regarding AviSynthPlus, both the official reference of ffmpeg and
# AviSynthPlus's own description introduce "Installing only C/C++
# header files". ffmpeg can enable "--enable-avisynth" with only these
# headers. The scenario is that the end user can install AviSynthPlus
# at any time he/she likes. But I choose to have "AviSynthPlus" installed
# in this docker container. This decision doesn't mean much, so if you
# don't like it, you can get rid of it yourself.
#
# Note that AviSynthPlus (unix variant build) at this time doesn't have
# quite a lot of the original Windows-specific features available. For
# example, "your first script" in "get started" doesn't work. This is
# because "AviSource" is not available.
# See https://github.com/AviSynth/AviSynthPlus/issues/162.
#
# ----------------------------------------------------------
# debian/ubuntu's package of AviSynthPlus doesn't exist.
WORKDIR /tmp/build
ADD https://github.com/AviSynth/AviSynthPlus/archive/v${_AVISYNTHPLUS_VERSION}.tar.gz .

RUN tar zxf v${_AVISYNTHPLUS_VERSION}.tar.gz && rm -fv v${_AVISYNTHPLUS_VERSION}.tar.gz
ENV AVISYNTHPLUS_SRCDIR=/tmp/build/AviSynthPlus-${_AVISYNTHPLUS_VERSION}
WORKDIR ${AVISYNTHPLUS_SRCDIR}/build
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" libdevil-dev "" "" || true ; \
     cmake -D CMAKE_BUILD_TYPE=RELEASE \
           -D BUILD_SHARED_LIBS=ON \
           -D CMAKE_INSTALL_PREFIX=${_PREFIX} \
           .. && \
         make -j $(grep "^core id" /proc/cpuinfo | wc -l) && \
         make install && echo ffmpeg:--enable-avisynth >> /tmp/build/_enable_if_available) || true

# ----------------------------------------------------------
#
# finally, full-build of ffmpeg.
#
# ----------------------------------------------------------
WORKDIR ${FFMPEG_SRCDIR}
# apply SVT-AV1's patch, if any (there is no patch for ffmpeg 5.1)
RUN (\
     (cd .. ; git clone https://github.com/AOMediaCodec/SVT-AV1.git) ; \
     for p in ../SVT-AV1/ffmpeg_plugin/n`basename \`pwd\` | sed 's@ffmpeg-\(.*\)\.[0-9]*$@\1@'`/*.patch ; \
     do patch -p1 < "$p" ; done) ; if $? -eq 0 ; then rm -fr SVT-AV1 ; else true ; fi

RUN (\
     sh `head -1 ffbuild/config.log | sed 's@^# @@' | \
           sed "s@--disable-ffplay@--enable-ffplay@" | \
           sed "s@--extra-version=[^ ][^ ]* @--extra-version=${_FFMPEG_EXTRA_VERSION_SUFFIX} @"` \
        --enable-gpl \
        --enable-version3 \
        \
        $(grep "^ffmpeg:" /tmp/build/_enable_if_available | sed 's@^ffmpeg:@@') && \
         make -j $(grep "^core id" /proc/cpuinfo | wc -l) && \
         make install \
    )
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
