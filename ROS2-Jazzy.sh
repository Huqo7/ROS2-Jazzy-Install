#!/bin/bash

################################
##### Check Ubuntu Version #####
################################

valid=false

while read line
do
    if [ "$line" = "VERSION_ID=\"24.04\"" ]; then
        valid=true
    fi
done < /etc/os-release

if ! $valid; then
    echo "Ubuntu Noble (24.04) was not detected"
    exit 1
fi

########################
##### Check Locale #####
########################

valid=false

while ! $valid; 
do

locales=$(locale)

for i in ${locales}
do
    if [[ $i == "LANG="*".UTF-8" ]]; then
        valid=true
    fi
done

if ! $valid; then
    echo "Locale does not support UTF-8"
    
    read -p "Would you like to change to en_US.UTF-8? [y/n]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    sudo apt install locales
    sudo locale-gen en_US en_US.UTF-8
    sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
    export LANG=en_US.UTF-8
fi
done

##########################
##### ROS 2 Packages #####
##########################

sudo apt install software-properties-common
sudo add-apt-repository universe

sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update && sudo apt install ros-dev-tools

sudo apt install ros-jazzy-desktop

if grep -Fxq "source /opt/ros/jazzy/setup.bash" ~/.bashrc
then
  echo "Already Sourced"
else 
  echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
fi

source /opt/ros/jazzy/setup.bash