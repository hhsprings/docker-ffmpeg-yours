#
ARG _BUILDPACKDEPS_TAG=22.10
ARG _FFMPEG_VERSION=4.4.2

# ----------------------------------------------------------
#
# build some third-party libraries from source, because the version
# of these managed by apt does not match the version expected by
# ffmpeg to be built, or because no deb package of it. 
# 
# ----------------------------------------------------------
FROM hhsprings/ffmpeg-yours-min:latest-${_FFMPEG_VERSION}-${_BUILDPACKDEPS_TAG} AS ffmpeg_base
RUN (\
     sh ${FFMPEG_SRCDIR}/configure --help | grep "^  *--.*able-" | grep -v = | \
         awk '{gsub(/--[endis]*able-/, "-"); print $1}' | \
         sort -u > /tmp/build/_ffmpeg_cfg_able)
#
FROM hhsprings/buildpack-deps-plus:latest-from-${_BUILDPACKDEPS_TAG} AS librav1e_build
ARG _LIBRAV1E_VERSION=0.5.1
RUN apt-get -q update
RUN apt-get install -yq --no-install-recommends nasm

COPY --from=ffmpeg_base /tmp/build/_ffmpeg_cfg_able /tmp/build/_ffmpeg_cfg_able

WORKDIR /tmp/build

# librav1e (OK on ubuntu:kinetic / NG on ubuntu:jammy)
#     librav1e is written by the "RUST language", we need a
#     "RUST compiler" to build it, but the resulting librav1e
#     does not depend on "something like RUST runtimes".
RUN (\
     if grep "^-librav1e$" /tmp/build/_ffmpeg_cfg_able ; then \
         apt-get install -yq --no-install-recommends cargo ; \
         wget -q https://github.com/xiph/rav1e/archive/refs/tags/v${_LIBRAV1E_VERSION}.tar.gz && \
             tar zxf v${_LIBRAV1E_VERSION}.tar.gz && rm -f v${_LIBRAV1E_VERSION}.tar.gz && \
             (cd rav1e-${_LIBRAV1E_VERSION} && \
                  (cargo install cargo-c && cargo cinstall --release)) && \
             echo ffmpeg:--enable-librav1e >> /tmp/build/_enable_if_available ; \
     fi \
    ) || true

# liblensfun
ARG _LIBLENSFUN_SSVERSION=5604b519fd0ea553655473dee359ee0b4bd0b11b
RUN (\
     if grep "^-liblensfun$" /tmp/build/_ffmpeg_cfg_able ; then \
         wget -q https://github.com/lensfun/lensfun/archive/${_LIBLENSFUN_SSVERSION}.zip && \
             unzip -qq ${_LIBLENSFUN_SSVERSION}.zip && mkdir lensfun-${_LIBLENSFUN_SSVERSION}/build && \
             (cd lensfun-${_LIBLENSFUN_SSVERSION}/build && \
                  (cmake -D CMAKE_BUILD_TYPE=Release .. && \
                       make -j $(grep "^core id" /proc/cpuinfo | wc -l) && make install)) && \
             echo ffmpeg:--enable-liblensfun >> /tmp/build/_enable_if_available ; \
     fi \
    ) || true

# libilbc (no deb package of this.)
ARG _ABSEIL_VERSION=20211102.0
ARG _LIBILBC_VERSION=3.0.4
RUN (\
     if grep "^-libilbc$" /tmp/build/_ffmpeg_cfg_able ; then \
         wget -q https://github.com/abseil/abseil-cpp/archive/refs/tags/${_ABSEIL_VERSION}.tar.gz && \
             tar zxf ${_ABSEIL_VERSION}.tar.gz && \
             wget -q https://github.com/TimothyGu/libilbc/archive/refs/tags/v${_LIBILBC_VERSION}.tar.gz && \
             tar zxf v${_LIBILBC_VERSION}.tar.gz && \
             (cd abseil-cpp-${_ABSEIL_VERSION} && \
                  mkdir build && cd build && \
                  cmake .. && make -j $(grep "^core id" /proc/cpuinfo | wc -l) && make install) && \
             (cd libilbc-${_LIBILBC_VERSION} && \
                  mkdir build && cd build && \
                  cmake .. && make -j $(grep "^core id" /proc/cpuinfo | wc -l) && make install) && \
             echo ffmpeg:--enable-libilbc >> /tmp/build/_enable_if_available ; \
     fi \
    ) || true

# "AVS"-related. Is AVS the Chinese standard? I don't know if this is
# popular at all, but at least I'm sure it's "confused" about the
# relationship between FFMPEG and AVS:
#
#   libxavs: AVS encoder (no DEB package, http://xavs.sourceforge.net/)
#   libxavs2: AVS2 encoder (It is registered in the DEB package.)
#   libdavs2: AVS2 decoder (no DEB package, https://github.com/pkuvcl/davs2)
#   libuavs3d: AVS3 decoder (no DEB package, https://github.com/uavs3/uavs3d)
#
# No AVS decoder, and no AVS3 encoder. In addition, ffmpeg follows
# the HEAD of the git repository instead of these release versions,
# which is very difficult to manage. Being able to use only the
# encoder is "nuisance", and even if you can only use the decoder,
# this is meaningless unless you "have video encoded with it". It
# would be worthless to apply libxavs without a corresponding decoder.
# It would be very unpleasant for us to apply libxavs2 because it's
# easy to apply, and not libdavs2 because it's not. I'm not sure if
# it's worth applying libuavs3d without a corresponding encoder.
# I don't know how popular it is. At least I've never seen a video
# encoded with this.
ARG _DAVS2_SSVER=b06d7585620f4e90a6d19a2926bb4e59793b8942
ARG _UAVS3D_SSVER=04d603d1a27ad924a1a9a02d2893fb3ae1ed67ad
RUN (\
     if grep "^-libdavs2$" /tmp/build/_ffmpeg_cfg_able ; then \
         (\
          git clone https://github.com/pkuvcl/davs2.git && \
              (\
               cd davs2 ; \
               git checkout ${_DAVS2_SSVER} ; \
               cd build/linux ; \
               ./configure --enable-shared --disable-static && \
                   make install && \
                   echo ffmpeg:--enable-libdavs2 >> /tmp/build/_enable_if_available \
              ) \
         ) ; \
     fi ; \
     if grep "^-libuavs3d$" /tmp/build/_ffmpeg_cfg_able ; then \
         (\
          git clone https://github.com/uavs3/uavs3d.git && \
              (\
               cd uavs3d ; \
               git checkout ${_UAVS3D_SSVER} ; \
               mkdir build/linux ; \
               cd build/linux ; \
               cmake -D BUILD_SHARED_LIBS=1 ../.. && \
                   make install && \
                   echo ffmpeg:--enable-libuavs3d >> /tmp/build/_enable_if_available \
              ) \
         ) ; \
     fi \
    ) || true

# libklvanc (no DEB package, and has no release version...)
ARG _LIBKLVANC_SSVER=74f01b7982a7caa18c800f14df30ca74cf142955
RUN (\
     if grep "^-libklvanc$" /tmp/build/_ffmpeg_cfg_able ; then \
         git clone https://github.com/stoth68000/libklvanc.git && \
             cd libklvanc/ && \
             git checkout ${_LIBKLVANC_SSVER} && \
             (./autogen.sh --build && \
                  ./configure --enable-shared --disable-static && \
                  make install) && \
             echo ffmpeg:--enable-libklvanc >> /tmp/build/_enable_if_available ; \
     fi \
    ) || true

# libkvazaar (no DEB package, and autogen.sh requires git clone)
ARG _LIBKVAZAAR_SSVER=cc22233117a90cb66b057024eb174aacc942a134
RUN (\
     if grep "^-libkvazaar$" /tmp/build/_ffmpeg_cfg_able ; then \
         git clone https://github.com/ultravideo/kvazaar.git && \
             cd kvazaar/ && \
             git checkout ${_LIBKVAZAAR_SSVER} && \
             (./autogen.sh && \
                  ./configure --enable-shared --disable-static && \
                  make $(grep "^core id" /proc/cpuinfo | wc -l) install) && \
             echo ffmpeg:--enable-libkvazaar >> /tmp/build/_enable_if_available ; \
     fi \
    ) || true

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
WORKDIR /tmp/build
COPY --from=librav1e_build /usr/local /usr/local
COPY --from=librav1e_build /tmp/build/_* /tmp/build

# ----------------------------------------------------------
#
# build opencv from source, because libopencv-dev of apt
# is broken or at least CRAZY in my humble opinion.
#
# ----------------------------------------------------------
# opencv from source
RUN /tmp/build/_apt_install.sh "ffmpeg" libgtk2.0-dev "" ""

# "-D OPENCV_GENERATE_PKGCONFIG=ON" has no effect if opencv 3.x, this is only for opencv 4+.
RUN (\
     wget -q https://github.com/opencv/opencv/archive/refs/tags/${_OPENCV_VERSION}.tar.gz && \
         tar zxf ${_OPENCV_VERSION}.tar.gz && rm -f ${_OPENCV_VERSION}.tar.gz && \
         mkdir -p opencv-${_OPENCV_VERSION}/build && \
         (\
          cd opencv-${_OPENCV_VERSION}/build && \
              cmake -D CMAKE_BUILD_TYPE=RELEASE \
                    -D BUILD_SHARED_LIBS=ON \
                    -D ENABLE_PIC=ON \
                    -D OPENCV_GENERATE_PKGCONFIG=ON \
                    -D BUILD_TESTS=OFF \
                    -D CMAKE_INSTALL_PREFIX=${_PREFIX} \
                    .. && \
              make -j $(grep "^core id" /proc/cpuinfo | wc -l) && make install && \
              echo ffmpeg:--enable-libopencv >> /tmp/build/_enable_if_available \
         ) ; \
     rm -fr opencv-${_OPENCV_VERSION} \
    )

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
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" libsdl2-dev "" "--enable-sdl2 --enable-sndio --enable-opengl" ; \
     /tmp/build/_apt_install.sh "ffmpeg" libpulse-dev "" --enable-libpulse ; \
     /tmp/build/_apt_install.sh "ffmpeg" libjack-dev "" --enable-libjack ; \
     /tmp/build/_apt_install.sh "ffmpeg" "libdc1394-dev libraw1394-dev" "" --enable-libdc1394 ; \
     /tmp/build/_apt_install.sh "ffmpeg" "libavc1394-dev libiec61883-dev" "" --enable-libiec61883 ; \
     /tmp/build/_apt_install.sh "ffmpeg" "libcdio-dev libcdparanoia-dev libcdio-cdda-dev libcdio-paranoia-dev libcdio-utils" "" --enable-libcdio \
    )

#
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" ocl-icd-opencl-dev "" --enable-opencl ; \
     /tmp/build/_apt_install.sh "ffmpeg" nvidia-opencl-dev "" --enable-opencl \
    )

#
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" libgnutls28-dev "" "--enable-gnutls" ; \
     if grep "^-librist$" /tmp/build/_ffmpeg_cfg_able ; then /tmp/build/_apt_install.sh "ffmpeg" librist-dev "" --enable-librist ; else true ; fi ; \
     /tmp/build/_apt_install.sh "ffmpeg" libbluray-dev "" --enable-libbluray ; \
     /tmp/build/_apt_install.sh "ffmpeg" librtmp-dev "" --enable-librtmp ; \
     /tmp/build/_apt_install.sh "ffmpeg" libsmbclient-dev "" --enable-libsmbclient ; \
     /tmp/build/_apt_install.sh "ffmpeg" libsrt-gnutls-dev "" --enable-libsrt ; \
     /tmp/build/_apt_install.sh "ffmpeg" libssh-dev "" --enable-libssh ; \
     /tmp/build/_apt_install.sh "ffmpeg" libzmq5-dev "" --enable-libzmq \
    )

RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" libx264-dev "" --enable-libx264 ; \
     /tmp/build/_apt_install.sh "ffmpeg" libx265-dev "" --enable-libx265 ; \
     /tmp/build/_apt_install.sh "ffmpeg" libvpx-dev "" --enable-libvpx ; \
     /tmp/build/_apt_install.sh "ffmpeg" libwebp-dev "" --enable-libwebp ; \
     /tmp/build/_apt_install.sh "ffmpeg" libaom-dev "" --enable-libaom ; \
     /tmp/build/_apt_install.sh "ffmpeg" libtheora-dev "" --enable-libtheora ; \
     if grep "^-libsvtav1$" /tmp/build/_ffmpeg_cfg_able ; then /tmp/build/_apt_install.sh "ffmpeg" libsvtav1enc-dev "" --enable-libsvtav1 ; else true ; fi ; \
     /tmp/build/_apt_install.sh "ffmpeg" libxvidcore-dev "" --enable-libxvid ; \
     /tmp/build/_apt_install.sh "ffmpeg" libmfx-dev "" --enable-libmfx ; \
     /tmp/build/_apt_install.sh "ffmpeg" libdav1d-dev "" --enable-libdav1d ; \
     /tmp/build/_apt_install.sh "ffmpeg" libopenh264-dev "" --enable-libopenh264 ; \
     if grep "^-libxavs2$" /tmp/build/_ffmpeg_cfg_able ; then \
         /tmp/build/_apt_install.sh "ffmpeg" libxavs2-dev "" --enable-libxavs2 ; \
     else true ; fi \
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

RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" libbs2b-dev "" --enable-libbs2b ; \
     /tmp/build/_apt_install.sh "ffmpeg" "libtesseract-dev libleptonica-dev tesseract-ocr-eng" "" --enable-libtesseract ; \
     /tmp/build/_apt_install.sh "ffmpeg" flite1-dev "" --enable-libflite ; \
     /tmp/build/_apt_install.sh "ffmpeg" libchromaprint-dev "" --enable-chromaprint ; \
     /tmp/build/_apt_install.sh "ffmpeg" librubberband-dev "" --enable-librubberband ; \
     /tmp/build/_apt_install.sh "ffmpeg" libzimg-dev "" --enable-libzimg ; \
     /tmp/build/_apt_install.sh "ffmpeg" libsoxr-dev "" --enable-libsoxr ; \
     /tmp/build/_apt_install.sh "ffmpeg" libmysofa-dev "" --enable-libmysofa ; \
     /tmp/build/_apt_install.sh "ffmpeg" libgme-dev "" --enable-libgme ; \
     /tmp/build/_apt_install.sh "ffmpeg" libgsm1-dev "" --enable-libgsm ; \
     /tmp/build/_apt_install.sh "ffmpeg" libopenmpt-dev "" --enable-libopenmpt ; \
     /tmp/build/_apt_install.sh "ffmpeg" libmodplug-dev "" --enable-libmodplug ; \
     /tmp/build/_apt_install.sh "ffmpeg" libvo-amrwbenc-dev "" --enable-libvo-amrwbenc ; \
     if grep "^-vulkan$" /tmp/build/_ffmpeg_cfg_able ; then /tmp/build/_apt_install.sh "ffmpeg" libvulkan-dev "" --enable-vulkan ; else true ; fi ; \
     if grep "^-libglslang$" /tmp/build/_ffmpeg_cfg_able ; then /tmp/build/_apt_install.sh "ffmpeg" glslang-dev "" --enable-libglslang ; else true ; fi ; \
     /tmp/build/_apt_install.sh "ffmpeg" libvidstab-dev "" --enable-libvidstab ; \
     /tmp/build/_apt_install.sh "ffmpeg" libzvbi-dev "" --enable-libzvbi ; \
     /tmp/build/_apt_install.sh "ffmpeg" libsnappy-dev "" --enable-libsnappy ; \
     /tmp/build/_apt_install.sh "ffmpeg" libgmp-dev "" --enable-gmp ; \
     /tmp/build/_apt_install.sh "ffmpeg" "libpocketsphinx-dev pocketsphinx-en-us" "" --enable-pocketsphinx ; \
     /tmp/build/_apt_install.sh "ffmpeg" libdrm-dev "" --enable-libdrm ; \
     /tmp/build/_apt_install.sh "ffmpeg" librsvg2-dev "" --enable-librsvg ; \
     if grep "^-librabbitmq$" /tmp/build/_ffmpeg_cfg_able ; then /tmp/build/_apt_install.sh "ffmpeg" librabbitmq-dev "" --enable-librabbitmq ; else true ; fi ; \
     /tmp/build/_apt_install.sh "ffmpeg" libaribb24-dev "" --enable-libaribb24 ; \
     /tmp/build/_apt_install.sh "ffmpeg" "libomxil-bellagio-dev libomxil-bellagio-bin" "" "--enable-omx" \
    )

#
# frei0r-plugins-dev don't install /usr/lib/frei0r-1 files.
RUN /tmp/build/_apt_install.sh "ffmpeg" "frei0r-plugins-dev frei0r-plugins" "" --enable-frei0r
ENV FREI0R_PATH=/usr/lib/frei0r-1

# The LADSPA plug-in that follows is not essential, so simply ignore the error.
RUN (\
     /tmp/build/_apt_install.sh "ffmpeg" ladspa-sdk "" --enable-ladspa ; \
     apt-get install ${__APT_Y} csladspa || true ; \
     apt-get install ${__APT_Y} bs2b-ladspa || true ; \
     apt-get install ${__APT_Y} guitarix-ladspa || true ; \
     apt-get install ${__APT_Y} invada-studio-plugins-ladspa || true ; \
     apt-get install ${__APT_Y} rubberband-ladspa || true \
    )
# Environment variable for /usr/bin/listplugins, etc.
ENV LADSPA_PATH=/usr/lib/ladspa

# "Lv2 is dead"? When I visit a site that claims to be a LV2 project, I can't
# find any "/plugins"  available in this ffmpeg lv2 filter. So at least the
# information about "the lv2 plugin that ffmpeg  wants to use" is completely
# obsolete. At least, I couldn't find a workable example at all.
#RUN /tmp/build/_apt_install.sh "ffmpeg" "liblilv-dev lilv-utils" "" --enable-lv2

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

RUN (\
     wget -q https://github.com/AviSynth/AviSynthPlus/archive/v${_AVISYNTHPLUS_VERSION}.tar.gz && \
         tar zxf v${_AVISYNTHPLUS_VERSION}.tar.gz && rm -f v${_AVISYNTHPLUS_VERSION}.tar.gz && \
         mkdir -p AviSynthPlus-${_AVISYNTHPLUS_VERSION}/build && \
         /tmp/build/_apt_install.sh "ffmpeg" libdevil-dev "" "" || true ; \
         (\
          cd AviSynthPlus-${_AVISYNTHPLUS_VERSION}/build && \
              cmake -D CMAKE_BUILD_TYPE=RELEASE \
                    -D BUILD_SHARED_LIBS=ON \
                    -D CMAKE_INSTALL_PREFIX=${_PREFIX} \
                    .. && \
              make -j $(grep "^core id" /proc/cpuinfo | wc -l) && \
              make install && echo ffmpeg:--enable-avisynth >> /tmp/build/_enable_if_available \
         ) ; rm -fr AviSynthPlus-${_AVISYNTHPLUS_VERSION} \
    ) || true

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
         make install && \
         make alltools ; rm -f tools/*.[od] \
    )
# The "tools" folder contains truly "chunky" tools. Some of them
# are unrelated to ffmpeg usage and are rather useful only to
# ffmpeg developers, while others are also valuable to general
# users, such as "graph2dot" which is also referenced from the
# official documentation. Everything contained here is almost
# undocumented. Even if it exists, it is only the comments in the
# source code. Therefore, these are "only used by those who understand"
# and are not supposed to be installed. However, I don't want
# "graph2dot" etc. to be ignored by that policy. Therefore, I decided
# to include this built tools folder in "PATH". Again, there are many
# tools in this that are of no value to you. If you don't understand
# how to use it, I recommend that you do not try to use it forcibly.
# (Especially, "trasher" is dangerous tool, so if you don't understand
# it by reading source code, NEVER use it.)
ENV PATH=${PATH}:${FFMPEG_SRCDIR}/tools
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
