for i in $(ls ~/.docker_images); do
    docker image load -i ~/.docker_images/$i
done
