cat >/Volumes/Tf/data/kspeeder/kspeeder.yaml <<EOF
services:
  kspeeder:
    image: linkease/kspeeder:latest
    container_name: kspeeder
    ports:
      - "5443:5443"
      - "5003:5003"
    volumes:
      - /Volumes/Tf/data/kspeeder/kspeeder-data:/kspeeder-data
      - /Volumes/Tf/data/kspeeder/kspeeder-config:/kspeeder-config
    restart: unless-stopped
EOF
cd /tmp
docker compose -f kspeeder.yaml up -d
