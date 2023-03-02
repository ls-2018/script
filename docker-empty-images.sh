i=${1-''}
docker builder prune -a -f
docker volume rm $(docker volume ls -qf dangling=true)
docker image prune --force
#docker system prune --volumes
docker system prune -a
#docker images | grep -v REPOSITORY |grep "$i"| awk '{print $3}' | xargs docker rmi --force
docker rmi --force $(docker images -q) || true
