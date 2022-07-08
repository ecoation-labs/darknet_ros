#!/usr/bin/env bash
source /opt/ros/noetic/setup.bash
cd /catkin_ws
# catkin build
source /catkin_ws/devel/setup.bash
export DISPLAY=:1
exec "$@"