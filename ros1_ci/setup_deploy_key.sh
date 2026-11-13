#!/bin/bash
# Creates SSH key Jenkins uses to read this repository (GitHub deploy key)
# and adds github.com to the known hosts Jenkins checks
# Based on Jenkins Basics for Robotics, 7.2 Install and Setup the Git Plugin (setup_ssh_git.sh)
# Changes:
#   - own key for this repository
#   - key and github.com host keys kept in ~/webpage_ws (saved with the rosject)
#   - host keys copied to ~/.ssh/known_hosts (also done by start_jenkins.sh on every start)
#   - no git config changes

# Exit on any error
set -e

# Prepare ssh key in the user workspace so it is stored with the rosject
KEY=~/webpage_ws/ros1_ci_deploy_key
mkdir -p ~/webpage_ws
if [ ! -f $KEY ]; then
    ssh-keygen -q -N '' -C 'ros1_ci jenkins' -f $KEY
fi

# github.com host keys, stored with the rosject
KNOWN_HOSTS=~/webpage_ws/known_hosts
if ! grep -q '^github.com ' $KNOWN_HOSTS 2> /dev/null; then
    ssh-keyscan github.com 2> /dev/null >> $KNOWN_HOSTS
fi

# Copy host keys to ~/.ssh/known_hosts (Jenkins default: Known hosts file), no duplicates
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/known_hosts
while read -r line; do
    grep -qxF -- "$line" ~/.ssh/known_hosts || echo "$line" >> ~/.ssh/known_hosts
done < $KNOWN_HOSTS

echo "1. Public key, add on GitHub: ros1_ci > Settings > Deploy keys > Add deploy key"
cat $KEY.pub
echo ""
echo "2. Private key, add in Jenkins: Manage Jenkins > Credentials > (global) > Add credentials"
echo "   Kind: SSH Username with private key, ID: ros1_ci_deploy_key, Description: ros1_ci deploy key,"
echo "   Username: git, Private Key: Enter directly"
cat $KEY
echo ""
echo "3. github.com host keys added to ~/.ssh/known_hosts, fingerprints should match GitHub's:"
ssh-keygen -lf $KNOWN_HOSTS
