docker rm kong --force
docker rm kong-database --force
docker rm konga --force
docker network rm kong-net
docker network create kong-net
# docker run -d --name kong-database \
#     --network=kong-net \
#     -p 9042:9042 \
#     cassandra:3
docker run -d --name kong-database \
	--network=kong-net \
	-p 5432:5432 \
	-e "POSTGRES_USER=kong" \
	-e "POSTGRES_DB=kong" \
	-e "POSTGRES_PASSWORD=kong" \
	postgres:9.6
sleep 10
docker run --rm \
	--network=kong-net \
	-e "KONG_DATABASE=postgres" \
	-e "KONG_PG_HOST=kong-database" \
	-e "KONG_PG_USER=kong" \
	-e "KONG_PG_PASSWORD=kong" \
	-e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
	kong:latest kong migrations bootstrap

docker run -d --name kong \
	--network=kong-net \
	-e "KONG_DATABASE=postgres" \
	-e "KONG_PG_HOST=kong-database" \
	-e "KONG_PG_USER=kong" \
	-e "KONG_PG_PASSWORD=kong" \
	-e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
	-e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
	-e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
	-e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
	-e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
	-e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
	-p 8000:8000 \
	-p 8443:8443 \
	-p 8001:8001 \
	-p 8444:8444 \
	kong:latest
# -e "KONG_DNS_RESOLVER=127.0.0.1:8600" \

docker run -d --network=kong-net -p 1337:1337 --name konga pantsel/konga
curl -i http://localhost:8001/
