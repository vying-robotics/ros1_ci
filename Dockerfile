# ROS Noetic + Gazebo, TortoiseBot simulation and tortoisebot_waypoints (Checkpoint 23)
# Based on Jenkins Basics for Robotics, Lesson 10.3 Create a Docker image
FROM osrf/ros:noetic-desktop-full-focal

# Tell container to use the C.UTF-8 locale for its language settings
ENV LANG C.UTF-8

# Print Python (ROS) output right away, so the Jenkins console shows it in order
ENV PYTHONUNBUFFERED=1

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Set up catkin workspace
WORKDIR /
RUN mkdir -p /catkin_ws/src
WORKDIR /catkin_ws/src

COPY ./tortoisebot /catkin_ws/src/tortoisebot
COPY ./tortoisebot_waypoints /catkin_ws/src/tortoisebot_waypoints

# build
WORKDIR /catkin_ws
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

# replace setup.bash in ros_entrypoint.sh
RUN sed -i 's|source "/opt/ros/\$ROS_DISTRO/setup.bash"|source "/catkin_ws/devel/setup.bash"|g' /ros_entrypoint.sh

# Script that starts simulation and runs waypoints tests
COPY ./run_waypoints_test.sh /run_waypoints_test.sh
RUN chmod +x /run_waypoints_test.sh

# Cleanup
RUN rm -rf /root/.cache

# Start a bash shell when container starts
CMD ["bash"]
