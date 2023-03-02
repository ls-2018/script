docker rm jaeger --force
echo 'docker run -p 16686:16686 -p 6831:6831/udp jaegertracing/all-in-one'
docker run -d --name jaeger -p 16686:16686 -p 6831:6831/udp jaegertracing/all-in-one
