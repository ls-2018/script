set -e
docker rm mydns --force
cd ~
homePath=$(pwd)
dataPath="$homePath/data/dns"
cd -
docker run -p 53:53/tcp -p 53:53/udp -p 9353:9353/tcp --name mydns --restart=always -v $dataPath:/var/landns -d acejilam/landns
