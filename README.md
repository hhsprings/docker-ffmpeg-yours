# docker-ffmpeg-yours
Ffmpeg on docker for you. [ffmpeg-yours-min](https://hub.docker.com/repository/docker/hhsprings/ffmpeg-yours-min), and [ffmpeg-yours-min](https://hub.docker.com/repository/docker/hhsprings/ffmpeg-yours-min) are created by this.

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
