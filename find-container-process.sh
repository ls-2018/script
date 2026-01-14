docker run --rm -it --name find-container-process \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--pid=host --net=host \
	--privileged \
	$(trans-image-name docker.io/80imike/find-container-process)
