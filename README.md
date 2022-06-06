# docker-ffmpeg-yours
Ffmpeg on docker for you. [ffmpeg-yours-min](https://hub.docker.com/r/hhsprings/ffmpeg-yours-min), and [ffmpeg-yours](https://hub.docker.com/r/hhsprings/ffmpeg-yours) are created by this.

The purpose of this project is not to provide off-the-shelf products, but to "provide a template for you to create ffmpeg (on docker) for yourself".

## What kind of people is it for?
First of all, this is for people who are dissatisfied with ffmpeg provided by linux distributors.
And this is for people who have some understanding of linux and are willing to build ffmpeg on their own.

## How to use this?
### If you just want to run the container I pushed to DockerHub.
This usage is not highly recommended.
This is because you may find it unpleasant because the size has become huge as a result of enabling the function to the extent that it is close to the full spec.
However, it's still worth it if you just want to try a filter that uses opencv, for example.

Since the Dockerfile does not contain CMD or ENTRYPOINT, you can run the commands installed in the container. You can run ffmpeg and ffprobe as belonging to the FFMPEG project. I disabled ffplay.

For example:
```
docker run --rm -it -v $(/bin/pwd)://wk -w //wk hhsprings/ffmpeg-yours \
    ffmpeg -y -i INPUT.mp3 -af 'asr,ametadata=mode=print' -f null - 2>&1 | tee asr_result.txt
```
```
docker run --rm -it -v $(/bin/pwd)://wk -w //wk hhsprings/ffmpeg-yours \
    -p 8888:8888 \
    ffmpeg -re -i INPUT.mkv -f flv tcp://0.0.0.0:8888?listen=1
```
Note that even if it is built, there are some that cannot be used with this single container alone.
For example, the RTMP protocol is enabled (--enable-rtmp), but you'll need to get help from something else, such as the nginx server.
There are many others that I have enabled without knowing if it works or what I should do to make it work.
Rather, they could be used to study "how to get them to work with Docker".

### If you want to create your own container based on this
There are two ways of thinking.

One thing is to simply copy the Dockerfile to your PC and edit it as you like. You might think it's a silly approach, but it's not wrong. My Dockerfile may be "overkill", so just get rid of what you think you don't need.

The other is to take over [ffmpeg-yours-min](https://hub.docker.com/r/hhsprings/ffmpeg-yours-min), or [ffmpeg-yours](https://hub.docker.com/r/hhsprings/ffmpeg-yours) by [FROM](https://docs.docker.com/engine/reference/builder/#from) in your Dockerfile.

```Dockerfile
FROM hhsprings/ffmpeg-yours

# Your container keeps the source of ffmpeg built by hhsprings/ffmpeg-yours
# and all the intermediate files at build time. You can reach the source
# tree with the environment variable FFMPEG_SRCDIR.
WORKDIR ${FFMPEG_SRCDIR}

# Install dependencies for any features you want to enable. (For example, TensorFlow.)
RUN apt-get install -yq --no-install-recommends libFUBAR-dev

# Reuse the configure option in my build and rerun configure.
RUN sh `head -1 ffbuild/config.log | sed 's@^# @@' | \
        sed "s@--extra-version=[^ ][^ ]* @--extra-version=yourbuild0.1 @"` \
        --enable-FUBAR

# Build and install.
RUN make -j $(grep "^core id" /proc/cpuinfo | wc -l)
RUN make install
```
As mentioned above, the source tree, intermediate files, etc. are all left unerased, so you may want to clean them up.
Also, you want to replace dependant packages -dev version to runtime version. In that case, for example you can:

```Dockerfile
FROM hhsprings/ffmpeg-yours AS ffmpeg-yours

# ...

# 22.10==kinetic. Make it the same as the one in "ffmpeg-yours".
FROM ubuntu:22.10
WORKDIR /tmp/build
COPY --from=ffmpeg-yours /usr/local /usr/local
COPY --from=ffmpeg-yours /tmp/build/_apt_install.sh.req-log /tmp/build/

# without noninteractive, "docker build" will stuck at (maybe) tzdata prompt.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q update && apt-get -y --no-install-recommends upgrade

ARG _PREFIX=/usr/local

# at least, you must set LD_LIBRARY_PATH, and consider setting, for example,
# "LADSPA_PATH" if necessary.
ENV LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:${LD_LIBRARY_PATH:-/usr/lib64:/usr/lib}
ENV PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH:-/usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig}

# "_apt_install.sh.req-log" contains all packages that I specified on "apt-get install"
# explicitly. In some cases, the "-dev" version and the non- "-dev" version have different
# names, so a simple replacement may not work. Here, if the installation of "non-dev version"
# fails, simply install "-dev version".
RUN for i in $(cat _apt_install.sh.req-log) ; do \
    apt-get install -y -q --no-install-recommends $(echo $i | sed 's@-dev$@@') || \
        apt-get install -y -q --no-install-recommends ${i} || true ; done

# if you want
#ENV DEBIAN_FRONTEND=readline
```

By the way, you can easily see the difference between /ffmpeg-yours and /ffmpeg-yours-min by reading my Dockerfile.

## About why I needed this
I wanted to use it for [this explanation](https://hhsprings.bitbucket.io/docs/programming/examples/ffmpeg/misc/ffmpeg_on_docker.html)
for casual users of ffmpeg. That is, I needed "freedom" for me rather than being perfect.

As I wrote in the link, there must be a container that is more suitable for you than mine.

