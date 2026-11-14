#!/bin/bash
# Runs inside ros1_ci Docker container (see Dockerfile and Jenkinsfile)
# Based on Jenkins Basics for Robotics, Lesson 7.3 Using Git Repositories in Jobs and Pipelines
# run_simulation.sh

source /catkin_ws/devel/setup.bash

# Show Gazebo GUI on the display passed to the container
if [ -n "$DISPLAY" ]; then GUI=true; else GUI=false; fi
echo "Gazebo GUI: $GUI (DISPLAY=$DISPLAY)"

# Start TortoiseBot simulation and waypoints action server in the background
# Capture the process ID of that launch in SIM_ID
roslaunch tortoisebot_waypoints waypoints_sim.launch gui:=$GUI &
SIM_ID=$!

# Wait for odometry and action server before running the tests
echo "Waiting for the simulation and the action server..."
timeout 120s bash -c 'until rostopic echo -n1 /odom > /dev/null 2>&1; do sleep 2; done' &&
timeout 60s bash -c 'until rostopic list 2> /dev/null | grep -q /tortoisebot_as/status; do sleep 2; done'
READY=$?

# Run waypoints tests from Checkpoint 23 (same as running them by hand)
if [ $READY -eq 0 ]; then
    rostest --reuse-master tortoisebot_waypoints waypoints_test.test
    TEST_RESULT=$?
else
    echo "Simulation or action server did not start"
    TEST_RESULT=1
fi

# Stop simulation and wait for Gazebo to shut down
# Pause physics and stop gzserver before the other nodes: stopping everything at once
echo "Stopping Gazebo..."
rosservice call /gazebo/pause_physics
pkill -TERM gzclient    # Gazebo GUI ignores SIGINT, stop it with SIGTERM
pkill -INT gzserver
timeout 30s bash -c 'while pgrep gzserver > /dev/null || pgrep gzclient > /dev/null; do sleep 1; done'
kill -INT $SIM_ID
wait $SIM_ID
if pgrep gzserver > /dev/null || pgrep gzclient > /dev/null; then
    echo "Gazebo is still running"
    TEST_RESULT=1
else
    echo "Gazebo shut down"
fi

exit $TEST_RESULT
