# | xargs -i docker save -o  $.tar.gz quay.io/kubernetes-ingress-controller/nginx-ingress-controller:master
mkdir -p /Volumes/Tf/docker_images
rm -rf /Volumes/Tf/docker_images/*
for i in $(docker images | grep -v REPOSITORY | awk -F ' ' '{printf("%s&%s&%s\n",$1,$2,$3)}'); do

	image=$(echo "$i" | cut -f1 -d "&")
	version=$(echo "$i" | cut -f2 -d "&")
	_id=$(echo "$i" | cut -f3 -d "&")
	echo $image $version $_id
	xx="${image//\//@}"
	docker save -o /Volumes/Tf/docker_images/$xx-$version.tar.gz $image:$version
done
