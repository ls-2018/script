docker rm stirling-pdf --force
cd ~
homePath=$(pwd)
dataPath="$homePath/data/pdf"
cd -

docker run -d \
	-p 8080:8080 \
	-v $dataPath/trainingData:/usr/share/tessdata \
	-v $dataPath/extraConfigs:/configs \
	-v $dataPath/logs:/logs \
	-e DOCKER_ENABLE_SECURITY=false \
	-e INSTALL_BOOK_AND_ADVANCED_HTML_OPS=false \
	-e LANGS=en_GB \
	--name stirling-pdf \
	$(trans_image_name.py docker.io/frooodle/s-pdf:1.3.2)
