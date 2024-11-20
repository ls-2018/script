# open -a '/Applications/Google Chrome.app' https://www.cnblogs.com/regit/p/17792451.html
# https://github.com/igxactly-forks/tutorial-rook-ceph-in-kind

cd ~
homePath=$(pwd)
dataPath="$homePath/data/ceph"


docker run -d --restart unless-stopped --pid=host --privileged -v "$dataPath/qemu-images:/data/qemu-images" -v '/dev:/dev' -e QCOW2_IMG_PATH=/data/qemu-images/developer.qcow2 -e NBD_DEV_PATH=/dev/nbd0 -e QCOW2_IMG_SIZE=60G -e VG_NAME=myvolgrp --name auto-nbd ghcr.io/protosam/auto-nbd

docker ps