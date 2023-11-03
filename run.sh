IMAGE_NAME=umrr-ros:latest
DOCKER_FILE=./Dockerfile
CONTAINER_NAME=umrr-ros

build_image()
{
	echo "Building docker image $IMAGE_NAME from $DOCKER_FILE"
	docker build . -t $IMAGE_NAME -f $DOCKER_FILE
}

run()
{
	# Allow the container to access the host's terminal 
	# Enable access to the host's USB and other devices
	# Allow loading of kernel modules (for peak_usb)
	# Mount the current directory into the container
	# Mount .vimrc file
	# Allow the container to display windows on the host's X Server
	# Allow the container to access the host's network freely
	# Source the ROS environment variables on startup
	# Run the container in the background

	docker run -e DISPLAY -e TERM \
		--privileged \
		-v "/dev:/dev:rw" \
		-v "/lib/modules:/lib/modules:rw" \
		-v "$(pwd):/code" \
		-v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
		-v "~/.vimrc:~/.vimrc:rw" \
		--net=host \
		--name $CONTAINER_NAME \
		--entrypoint /ros_entrypoint.sh \
		-d $IMAGE_NAME /usr/bin/tail -f /dev/null

}

attach_to_container()
{
	# Allow docker windows to show on our current X Server
	xhost + >> /dev/null

	# Start the container in case it's stopped
	docker start $CONTAINER_NAME

	exec docker exec -it $CONTAINER_NAME bash
}

case "$1" in
"build")
    build_image
    ;;
"pull")
    docker pull $IMAGE_NAME
    ;;
"rm")
    if [[ $2 ]] ; then
        NAME_SUFFIX=$2
        CONTAINER_NAME="${CONTAINER_NAME}_${NAME_SUFFIX}"
    fi
    docker rm -f $CONTAINER_NAME
    echo "Removed container"
    ;;
"--help")
    echo "Usage: docker/run.sh [command] [name]
Available commands:
    run.sh [-n name]
        Attach a new terminal to the container (pulling/building, creating and starting it if necessary).
        If supplied, the container will be given a specific name.
    run.sh build 
        Build a new image from the Dockerfile in the current directory.
    run.sh rm [-n name]
        Remove the container.
        If name is supplied, it will remove the container with that name
    run.sh --help
        Show this help message    
    "
    ;;
*) # Attach a new terminal to the container (pulling, creating and starting it if necessary)
    if [[ $1 ]] ; then
        CONTAINER_NAME=$1
    fi

    if [ -z "$(docker images -f reference=$IMAGE_NAME -q)" ]; then # if the image does not yet exist, pull it
	build_image
    fi
    if [ -z "$(docker ps -qa -f name=$CONTAINER_NAME)" ]; then # if container has not yet been created, create it
	run
    fi
    attach_to_container
    ;;
esac
