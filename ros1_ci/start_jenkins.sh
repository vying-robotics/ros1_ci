#!/bin/bash
# Based on Jenkins Basics for Robotics, Unit 2.1 Installing Jenkins (start_jenkins.sh)
# Changes: Jenkins 2.479.3 (newer versions fail login behind the Academy proxy),
# starts Docker for the CI jobs (installs it with ros1_ci/install_docker.sh if missing), no drone commands

# Exit on any error. If something fails, there's no use
# proceeding further because Jenkins might not be able
# to run in that case
set -e

# Set the JENKINS_HOME environment variable. This will cause
# Jenkins will run from this directory.
# Create the JENKINS_HOME directory if it doesn't exist.
export JENKINS_HOME=~/webpage_ws/jenkins
mkdir -p $JENKINS_HOME

# Install java
sudo apt-get update -y || true
sudo apt-get install -y openjdk-21-jre

# Start Docker (the CI jobs build and run Docker images) and allow Jenkins to use it
# Docker is not kept when the rosject restarts: install it again if missing
if command -v docker > /dev/null; then
    sudo service docker start || true
    sleep 3s
    sudo chmod 666 /var/run/docker.sock
else
    bash ~/simulation_ws/src/ros1_ci/install_docker.sh
fi

# Download the Jenkins .war file, if not there already
cd ~
JENKINS_FILE="/home/user/jenkins.war"
if [ ! -f "$JENKINS_FILE" ]; then
    wget https://updates.jenkins.io/download/war/2.479.3/jenkins.war
fi

# Jenkins is about to run, but we must check if
# it's is already running
string=`ps ax | grep jenkins`
if [[ $string == *"jenkins.war"* ]]; then
    # Don't proceed further. Jenkings is already running
    echo "Jenkins is running already. Exiting."
    exit 0
else
    # Start Jenkins, since it's not running yet.
    # Run Jenkins with a prefix. A prefix is needed because we are using a
    # reverse proxy to run it on the Academy. This may not be necessary in your setup.
    # Store Jenkins proceess ID in JENKINS_PID
    java -jar jenkins.war --prefix="/$SLOT_PREFIX/jenkins/" &
    JENKINS_PID=$!
    sleep 15s

    # Calculate the Jenkins proxy address
    # This is NOT required for running Jenkins. It's just something we
    # need to do on the Academy. INSTANCE_ID and SLOT_PREFIX are Academy variables.
    INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
    URL=`echo "https://$INSTANCE_ID.robotigniteacademy.com/$SLOT_PREFIX/jenkins/"`

    echo ""
    echo "1. Jenkins is running in the background."
    echo "2. Switch to the webpage tab to see it."

    # Create a file that will store vital information
    # about the Jenkins instance
    # Save the running instance info to the file
    # This is just for your convenience
    STATE_FILE=~/jenkins__pid__url.txt
    touch $STATE_FILE
    echo "To stop Jenkins, run:" > $STATE_FILE
    echo "kill $JENKINS_PID" >> $STATE_FILE
    echo "" >> $STATE_FILE
    echo "Jenkins URL: " >> $STATE_FILE
    echo $URL >> $STATE_FILE

    echo "3. See '$STATE_FILE' for Jenkins PID and URL."
fi
