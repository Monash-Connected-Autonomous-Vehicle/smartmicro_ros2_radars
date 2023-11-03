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
