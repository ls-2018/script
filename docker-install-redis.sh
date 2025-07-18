docker rm myRedis --force
cd ~
homePath=$(pwd)
dataPath="$homePath/data/redis"
cd -
#docker run -itd --name myRedis -p 26379:6379 --restart=always -v /data/redis:/data registry.cn-hangzhou.aliyuncs.com/acejilam/redis:7.0 --requirepass "123456"
docker run -itd --name myRedis -p 6379:6379 --restart=always -v $dataPath:/data registry.cn-hangzhou.aliyuncs.com/acejilam/redis:7.0
