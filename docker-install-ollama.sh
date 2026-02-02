#! /usr/bin/env zsh
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
source "$SCRIPT_DIR/.alias.sh"

set -x
docker rm -f ollama open-webui

docker network create -d bridge ollama-network || true

docker run -d \
	-v ~/.ollama:/root/.ollama \
	-p 11434:11434 \
	--name ollama \
	--network ollama-network \
	$(trans-image-name docker.io/ollama/ollama:0.15.2)

docker run -d -p 3100:8080 \
	-v open-webui:/app/backend/data \
	-e OLLAMA_BASE_URL=http://ollama:11434 \
	--name open-webui \
	--network ollama-network \
	--restart always \
	$(trans-image-name ghcr.io/open-webui/open-webui:main)

ollama pull deepseek-r1:1.5b
sleep 10
open -a "/Applications/Google Chrome.app" "http://127.0.0.1:3100"
