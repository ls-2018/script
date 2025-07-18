docker rm zookeeper --force
docker rm kafka --force
ip=$(ifconfig | grep 'inet ' | grep -E "(10|192)" | awk '{print $2}')
docker run -d --name zookeeper -p 2181:2181 wurstmeister/zookeeper
docker run -d --name kafka -p 9092:9092 \
	-e KAFKA_BROKER_ID=0 \
	-e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --link zookeeper \
	-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://${ip}:9092 \
	-e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 \
	wurstmeister/kafka

# docker exec -it kafka /bin/sh
# cd /opt/kafka/bin
# ./kafka-console-producer.sh --broker-list localhost:9092 --topic sun
# ./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic sun --from-beginning
