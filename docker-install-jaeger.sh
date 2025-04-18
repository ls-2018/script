docker rm jaeger --force
docker run -d --name jaeger \
	-e COLLECTOR_ZIPKIN_HOST_PORT=:9411 \
	-e COLLECTOR_OTLP_ENABLED=true \
	-p 6831:6831/udp \
	-p 6832:6832/udp \
	-p 5778:5778 \
	-p 16686:16686 \
	-p 4317:4317 \
	-p 4318:4318 \
	-p 14250:14250 \
	-p 14268:14268 \
	-p 14269:14269 \
	-p 9411:9411 \
	registry.cn-hangzhou.aliyuncs.com/acejilam/all-in-one

open -a "/Applications/Google Chrome.app" "http://127.0.0.1:16686/search"
