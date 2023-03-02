docker rm myRedis --force
cd ~
homePath=$(pwd)
dataPath="$homePath/data/redis"
cd -
#docker run -itd --name myRedis -p 6379:6379 --restart=always  redis --requirepass"123456"
docker run -itd --name myRedis -p 6379:6379 --restart=always -v $dataPath:/data redis:7.0
