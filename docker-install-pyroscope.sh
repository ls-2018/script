docker rm pyroscope --force
docker run -d --name pyroscope -p 4040:4040 pyroscope/pyroscope:latest server
