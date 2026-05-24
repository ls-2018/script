#!/usr/bin/env bash
set -x
host=${1-172.20.51.4}
image=${2-unknown}

docker pull ${image}
docker save -o /Volumes/Tf/docker_images/x.tar.gz ${image}
rsync -avz --progress /Volumes/Tf/docker_images/x.tar.gz root@${host}:/tmp/x.tar.gz

ssh root@${host} "docker load -i /tmp/x.tar.gz || ctr i import /tmp/x.tar.gz"
