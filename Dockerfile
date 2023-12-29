FROM osrf/ros:noetic-desktop-full-focal AS base
# deactivate interactive package manager
ENV DEBIAN_FRONTEND noninteractive
# install locales
RUN apt update
RUN apt install apt-utils wget locales -y
# Set the locale
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
# set linke library path
ENV LD_LIBRARY_PATH /usr/local/lib
# change directory to the place where all the installations happen
WORKDIR /install
# install ros-independent libraries
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    neovim byobu \
    build-essential gdb wget curl xz-utils libc++-dev git \
    python3 python3-pip python3-virtualenv python-is-python3 ipython3 python3.8-venv \
    libopencv-dev libeigen3-dev libgtest-dev openssl libssl-dev \
    libssl-dev libusb-1.0-0 libusb-1.0-0-dev libudev-dev pkg-config libgtk-3-dev \
    xorg-dev libglu1-mesa-dev freeglut3-dev doxygen \
    gnupg apt-transport-https lsb-release \
    libgoogle-glog-dev libglfw3 libglfw3-dev ros-noetic-jsk-rviz-plugins liblua5.2-dev \
    software-properties-common \
    && \
    rm -rf /var/lib/apt/lists/*
FROM base as mid360_driver
# install Livox-SDK2 which is a dependency for the ROS driver
WORKDIR /install
RUN git clone https://github.com/Livox-SDK/Livox-SDK2.git && cd ./Livox-SDK2 && \
    mkdir build && cd build && cmake .. && make -j && make install
# make VTK (https://docs.vtk.org/en/latest/index.html) symlink to version-less folder
RUN ln -s /usr/bin/vtk7 /usr/bin/vtk
# install mid360 driver
WORKDIR /catkin_ws/src
# clone the driver repo
RUN git clone https://github.com/Livox-SDK/livox_ros_driver2.git
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && /catkin_ws/src/livox_ros_driver2/build.sh ROS1"
FROM mid360_driver AS development
WORKDIR /catkin_ws
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc
RUN echo "source /catkin_ws/devel/setup.bash" >> /root/.bashrc
RUN apt-get update && apt-get install -y -q iputils-ping && \
    rm -rf /var/lib/apt/lists/*
FROM base as delpoy
WORKDIR /catkin_ws
# copy the package containing the lidar launch files
COPY ./mid360_runner /catkin_ws/src/mid360_runner
# build to register the runner package
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"
