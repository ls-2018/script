mkdir -p /Volumes/Tf/data/registry

delete=${1-}
if [[ ${delete} == "delete" ]]; then
	rm -rf /Volumes/Tf/data/registry/*
fi

docker rm simple_registry -f
docker rm simple_registry-ui -f

docker run -d -v /Volumes/Tf/data/registry:/var/lib/registry \
	-e REGISTRY_STORAGE_DELETE_ENABLED=true \
	-p 5000:5000 --restart=always --name simple_registry $(trans-image-name docker.io/library/registry:3)

docker run -p 8280:80 --restart=always --name simple_registry-ui \
	--link simple_registry:simple_registry \
	-e REGISTRY_URL="http://simple_registry:5000" \
	-e DELETE_IMAGES="true" \
	-e REGISTRY_TITLE="Registry2" \
	-e CATALOG_ELEMENTS_LIMIT="1000" \
	-d $(trans-image-name docker.io/joxit/docker-registry-ui:1.5-static)

open -a "/Applications/Google Chrome.app" "http://127.0.0.1:8280"
