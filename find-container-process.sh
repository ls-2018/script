docker run --rm -it --name find-container-process \
	-v /var/run/docker.sock:/var/run/docker.sock \
	--pid=host --net=host \
	--privileged \
	$(trans_image_name.py docker.io/80imike/find-container-process)
