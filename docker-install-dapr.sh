# docker
docker rm dapr_redis --force
docker run -itd --name dapr_redis -p 6379:6379 redis

docker rm dapr_zipkin --force
docker run -itd --name dapr_zipkin -p 9411:9411 openzipkin/zipkin

#docker rm dapr_placement --force
#docker run -itd --name dapr_placement -p 50005:50005 daprio/dapr
