set -ex
docker rm clickhouse-server --force

docker run \
	-p 8123:8123 \
	-p 9000:9000 \
	-p 9009:9009 \
	--name clickhouse-server \
	--ulimit nofile=262144:262144 \
	-e CLICKHOUSE_DB=test \
	-e CLICKHOUSE_USER=root \
	-e CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1 \
	-e TZ=Asia/Shanghai \
	-e CLICKHOUSE_PASSWORD=123456 \
	-d registry.cn-hangzhou.aliyuncs.com/acejilam/clickhouse-server
