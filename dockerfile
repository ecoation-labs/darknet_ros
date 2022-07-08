FROM osrf/ros:noetic-desktop-full

RUN apt-get update && apt-get -y install \
    python3-pip \
    git \
    ros-noetic-catkin python3-catkin-tools \
    ros-noetic-usb-cam \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    wget

# RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
# RUN mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
# RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
# RUN add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
# RUN apt-get update && apt-get -y install cuda

RUN apt-get update && apt-get -y upgrade

SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /catkin_ws/src
COPY . ../catkin_ws/src/darknet_ros
WORKDIR /catkin_ws

RUN /bin/bash -c "source /opt/ros/noetic/setup.bash \
        && catkin build"

RUN echo 'source "/opt/ros/noetic/setup.bash"' >> ~/.bashrc \
    && echo 'source "/catkin_ws/devel/setup.bash"' >> ~/.bashrc

ENV DEBIAN_FRONTEND=interactive

ADD ros_entrypoint.sh /usr/bin/ros_entrypoint
RUN chmod +x /usr/bin/ros_entrypoint

ENTRYPOINT [ "ros_entrypoint" ]