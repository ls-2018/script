docker rm $(docker ps -a -q --filter status=exited)
docker volume rm $(docker volume ls -f dangling=true --format '{{.Name}}')
docker rmi $(docker images -aq -f dangling=true)
