docker builder prune -a -f
# docker system prune --volumes
#docker ps -a | grep -v CONTAINER | awk '{print $1}' | xargs docker rm --force
docker ps -a -q | xargs docker rm --force

