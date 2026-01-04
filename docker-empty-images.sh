# Remove all unused images, not just dangling ones
docker builder prune -a -f

docker images -f dangling=true -q | xargs docker rmi --force
docker volume ls -qf dangling=true | docker volume rm
# Remove dangling images
docker image prune --force
#docker system prune --volumes
docker system prune -a
#docker images | grep -v REPOSITORY |grep "$i"| awk '{print $3}' | xargs docker rmi --force
docker images -q | xargs docker rmi --force
