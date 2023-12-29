#!/bin/bash
xhost + 
docker run \
    --rm \
    --name mid360 \
    -it \
    --privileged \
    --network host \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /dev:/dev \
    -v $(pwd):/catkin_ws/src/mid360 \
    mid360_driver:latest
bash
xhost -
