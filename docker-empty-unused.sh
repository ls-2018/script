
docker volume rm $(docker volume ls -f dangling=true --format '{{.Name}}')
docker rmi $(docker images -aq)