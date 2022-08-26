FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

# install ros noetic
SHELL ["/bin/bash", "-c"]
RUN echo 'Etc/UTC' > /etc/timezone &&     ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime &&     apt-get update &&     apt-get install -q -y --no-install-recommends tzdata &&     rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -q -y --no-install-recommends     dirmngr     gnupg2     && rm -rf /var/lib/apt/lists/*
RUN echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros1-latest.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV ROS_DISTRO=noetic
RUN apt-get update && apt-get install -y --no-install-recommends     ros-noetic-ros-core=1.5.0-1*     && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install --no-install-recommends -y     build-essential     python3-rosdep     python3-rosinstall     python3-vcstools     && rm -rf /var/lib/apt/lists/*
RUN rosdep init &&   rosdep update --rosdistro $ROS_DISTRO
RUN apt-get update && apt-get install -y --no-install-recommends     ros-noetic-ros-base=1.5.0-1*     && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends     ros-noetic-robot=1.5.0-1*     && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y --no-install-recommends     ros-noetic-desktop=1.5.0-1*     && rm -rf /var/lib/apt/lists/* # buildkit
RUN apt-get update && apt-get install -y --no-install-recommends     ros-noetic-desktop-full=1.5.0-1*     && rm -rf /var/lib/apt/lists/* # buildkit

# install other packages and dependencies
RUN apt-get update && apt-get -y install \
    python3-pip \
    git \
    ros-noetic-catkin python3-catkin-tools \
    ros-noetic-usb-cam \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    wget

# setup and complie code  
ENV DEBIAN_FRONTEND=noninteractive
RUN mkdir -p /catkin_ws/src
COPY . ../catkin_ws/src/darknet_ros

WORKDIR /catkin_ws/src/darknet_ros/darknet_ros/yolo_network_config/weights/
RUN wget http://pjreddie.com/media/files/yolov3-tiny.weights
RUN wget http://pjreddie.com/media/files/yolov3.weights

WORKDIR /catkin_ws
    
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash \
        && catkin build darknet_ros -DCMAKE_BUILD_TYPE=Release"
RUN echo 'source "/opt/ros/noetic/setup.bash"' >> ~/.bashrc \
    && echo 'source "/catkin_ws/devel/setup.bash"' >> ~/.bashrc

ENV DEBIAN_FRONTEND=interactive
ENV LD_LIBRARY_PATH = $LD_LIBRARY_PATH:/usr/local/cuda/lib64

# execute
ADD ros_entrypoint.sh /usr/bin/ros_entrypoint.sh
RUN chmod +x /usr/bin/ros_entrypoint.sh

ENTRYPOINT [ "ros_entrypoint.sh" ]