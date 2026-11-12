# ros1_ci

Jenkins CI for the Checkpoint 23 `tortoisebot_waypoints` tests (ROS Noetic, TortoiseBot simulation in Gazebo)

## Packages
- `tortoisebot/` - TortoiseBot simulation packages
- `tortoisebot_waypoints/` - waypoints action server and tests from Checkpoint 23
  - `launch/waypoints_sim_headless.launch` (simulation without Gazebo GUI + action server)
- `ros1_ci/` - Checkpoint 24 files (this folder):
  - `Dockerfile` - ROS Noetic + Gazebo image with both packages built
  - `run_waypoints_test.sh` - runs in the container: 
    1. Starts the simulation
    2. Runs tests
    3. Shuts Gazebo down
  - `install_docker.sh` - installs and starts Docker in the rosject
  - `install_jenkins_plugins.sh` - downloads the Jenkins plugins (Pipeline + Git), versions for Jenkins 2.479.3
  - `start_jenkins.sh` - starts Docker and Jenkins (Jenkins home `~/webpage_ws/jenkins`)
  - `Jenkinsfile` - Jenkins pipeline: 
    1. Builds docker image
    2. Runs tests in container

## Docker setup

The rosject does not come with Docker. Installation and execution needed

```bash
bash ~/simulation_ws/src/ros1_ci/install_docker.sh
```

Notes:
- `install_docker.sh` is The Construct's `~/ros2_ws/src/fastbot/docker/install_docker.sh` with no prompts, plus:
  - `containerd.io` 1.7.23 (held), includes runc 1.1.14
    - Newer runc (1.2+) can't start containers in the rosject (`error mounting "proc" to rootfs at "/proc"`)
  - Starts Docker and `chmod 666 /var/run/docker.sock` (allows `user` and Jenkins to use Docker)
  - `x11-xserver-utils` provides `xhost`, to show Gazebo from container
- If Docker is already installed but stopped (`docker ps` fails):
  - `sudo service docker start && sudo chmod 666 /var/run/docker.sock` (Docker recreates the socket on every start)

## Building and Running containerized tests manually

Build Docker image:

```bash
cd ~/simulation_ws/src
docker build -f ros1_ci/Dockerfile -t ros1_ci .
```

Terminal 1, start container and TortoiseBot simulation:

```bash
xhost +local:root
docker run --rm -it --name ros1_ci_container -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ros1_ci
roslaunch tortoisebot_gazebo tortoisebot_playground.launch
```

Terminal 2, start waypoints action server in same container:

```bash
docker exec -it ros1_ci_container bash
source /catkin_ws/devel/setup.bash
rosrun tortoisebot_waypoints tortoisebot_action_server.py
```

Terminal 3, run waypoints tests:

```bash
docker exec -it ros1_ci_container bash
source /catkin_ws/devel/setup.bash
rostest --reuse-master tortoisebot_waypoints waypoints_test.test
```

The robot drives to the goal twice, giving result `RESULT: SUCCESS` with `TESTS: 2`. (For the failing tests use `waypoints_failing_test.test`.)

Same tests in one command, without Gazebo GUI (what Jenkins runs):

```bash
docker run --rm ros1_ci /run_waypoints_test.sh
```

## Jenkins setup (run once)

Jenkins 2.479.3 used, appropriate plugin versions pinned for it

1. Download plugins (with Jenkins not running):

```bash
bash ~/simulation_ws/src/ros1_ci/install_jenkins_plugins.sh
```

2. Start Jenkins, print initial admin password and Jenkins URL:

```bash
bash ~/simulation_ws/src/ros1_ci/start_jenkins.sh
cat ~/webpage_ws/jenkins/secrets/initialAdminPassword
cat ~/jenkins__pid__url.txt
```

3. Open Jenkins URL, paste initial admin password:
   - **Select plugins to install** > **None** > **Install** (plugins already downloaded)
   - **Skip and continue as admin** > **Not now** > **Start using Jenkins**
   - Change admin password: **admin** > **Configure** > **Password** > **Save**

4. Create  project: **New Item** > `ros1_ci` > **Pipeline** > **OK**
   - Triggers: **Poll SCM**, Schedule `* * * * *` (checks repository every minute)
   - Pipeline: **Pipeline script from SCM**
     - SCM **Git**, Repository URL `https://github.com/vying-robotics/ros1_ci.git` (public, no credentials)
     - Branch Specifier `*/main`
     - Script Path `ros1_ci/Jenkinsfile`
   - **Save**, then **Build Now** once (first build downloads the ROS Noetic image, which takes several minutes; Poll SCM compares new commits with it)

## Start Jenkins

```bash
bash ~/simulation_ws/src/ros1_ci/start_jenkins.sh
cat ~/jenkins__pid__url.txt
```

- `start_jenkins.sh` installs Java and starts Docker (installs Docker if missing after a rosject restart)

Open Jenkins URL printed by the last command and log in:

- Username: `admin`
- Password: `password`

## Test with a pull request

1. Create pull request on `https://github.com/vying-robotics/ros1_ci` (e.g. add a small `.txt` file).
2. Accept pull request and merged into `main`
3. Jenkins starts a new build of `ros1_ci`
4. Open build under **Build History** > **Console Output**:
   - `Build Docker image`: image build
   - `Run waypoints tests`: Gazebo + action server start, robot drives to goal twice, `rostest` summary `RESULT: SUCCESS`, `Stopping Gazebo...`, `Gazebo shut down`
   - Desired result, `Finished: SUCCESS`
