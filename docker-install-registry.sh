mkdir -p /Users/acejilam/data/registry

delete=${1-}
if [[ ${delete} == "delete" ]]; then
	rm -rf /Users/acejilam/data/registry/*
fi

docker rm simple_registry -f
docker rm simple_registry-ui -f

docker run -d -v /Users/acejilam/data/registry:/var/lib/registry \
	-e REGISTRY_STORAGE_DELETE_ENABLED=true \
	-p 5000:5000 --restart=always --name simple_registry registry.cn-hangzhou.aliyuncs.com/acejilam/registry:latest

docker run -p 8280:80 --restart=always --name simple_registry-ui \
	--link simple_registry:simple_registry \
	-e REGISTRY_URL="http://simple_registry:5000" \
	-e DELETE_IMAGES="true" \
	-e REGISTRY_TITLE="Registry2" \
	-e CATALOG_ELEMENTS_LIMIT="1000" \
	-d registry.cn-hangzhou.aliyuncs.com/acejilam/docker-registry-ui:1.5-static

open -a "/Applications/Google Chrome.app" "http://127.0.0.1:8280"
