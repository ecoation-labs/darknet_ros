#!/bin/bash
source /opt/ros/noetic/setup.bash
cd /catkin_ws
source /catkin_ws/devel/setup.bash
export DISPLAY=:1
exec "$@"