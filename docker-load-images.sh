set -x
for i in $(ls /Volumes/Tf/docker_images); do
	docker image load -i /Volumes/Tf/docker_images/$i
done
