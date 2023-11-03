FROM osrf/ros:foxy-desktop

RUN apt-get update && apt-get install -y \
    iputils-ping \
    python3 \
    python3-pip \
    ros-foxy-point-cloud-msg-wrapper \
    wget \
    tmux \
    vim

WORKDIR /code
RUN /bin/bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash; colcon build; source install/setup.bash'

# Add source commands to bashrc
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc
# Change prompt to show we are in a docker container
RUN echo "export PS1='\[\e]0;\u@docker: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@docker\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" >> /root/.bashrc
