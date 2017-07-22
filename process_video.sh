#!/bin/sh 
#
# Script to extract frames, process with deepdream,
# and generate a resulting movie.
#
# Usage:
# ./process_video.sh <source_video> <destination>

# Clean up
mkdir /tmp/images 2>/dev/null
rm /tmp/images/* 2> /dev/null
rm deepdream/inputs/* 2>/dev/null
rm deepdream/outputs/* 2>/dev/null
rm /tmp/video.mp4 2>/dev/null
docker rm deepdream-compute 2>/dev/null

# Process the video
cp $1 /tmp/video.mp4
docker run -it --rm -v /tmp:/tmp aquarius212/ffmpeg /bin/bash -c "ffmpeg -i /tmp/video.mp4 -r 29.97 -f image2 /tmp/images/image-%05d.jpg"
cp /tmp/images/image*jpg deepdream/inputs/
docker run --name deepdream-compute --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl --device /dev/nvidia-uvm:/dev/nvidia-uvm -v `pwd`/deepdream:/opt/deepdream -d tleyden5iwx/caffe-gpu-master /bin/bash -c "cd /opt/deepdream && ./process_images.sh 2>&1 > log.html"
cp -R deepdream/outputs /tmp/
rm /tmp/out.mp4 2> /dev/null
docker run -it --rm -v /tmp:/tmp aquarius212/ffmpeg /bin/bash -c "ffmpeg -f image2 -r 29.97 -i /tmp/outputs/image-%05d.jpg -b 600k -vf \"scale=trunc(iw/2)*2:trunc(ih/2)*2\" /tmp/out.mp4"
cp /tmp/out.mp4 deepdream/
