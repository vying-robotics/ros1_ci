#!/bin/bash
# Installs and starts Docker in rosject
# Based on ~/ros2_ws/src/fastbot/docker/install_docker.sh, changes:
#   - no prompts (-y)
#   - containerd.io pinned to 1.7.23 (runc 1.1.14)
#   - starts Docker,
#   - opens the Docker socket
#   - installs xhost (to show Gazebo)

# Exit on any error
set -e

# DEBIAN_FRONTEND=noninteractive after sudo (sudo drops environment variables):
# no configuration prompts (e.g. tzdata time zone) while installing

# Uninstall all conflicting packages (not installed is fine)
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo DEBIAN_FRONTEND=noninteractive apt-get remove -y $pkg || true; done

# Add Docker's official GPG key:
sudo apt-get update -y || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update -y

# Install Docker packages:
# containerd.io 1.7.23 includes runc 1.1.14
#   - Newer runc (1.2+) can't start containers
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades docker-ce docker-ce-cli containerd.io=1.7.23-1 docker-buildx-plugin docker-compose-plugin
sudo apt-mark hold containerd.io

# xhost, to show Gazebo from container
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y x11-xserver-utils

# Start Docker
# (Docker recreates socket on every start, so chmod is needed after each start)
sudo service docker start || true
for i in $(seq 1 10); do
    [ -S /var/run/docker.sock ] && break
    sleep 1s
done
sudo chmod 666 /var/run/docker.sock

docker --version
runc --version | head -1
