docker rm nacos --force
docker run --restart=always --env MODE=standalone --name nacos -d -p 8848:8848 $(trans-image-name docker.io/nacos/nacos-server:v3.1.1)

echo "
usage
    \033[4mhttps://127.0.0.1:8848/nacos\033[0m
    nacos nacos
"
