#!/usr/bin/env bash

if [ "$1" = "go" ]; then
	export GO111MODULE=off
	export https_proxy=http://10.10.10.20:1081
	# validate
	go get -v -d github.com/envoyproxy/protoc-gen-validate
	go get -v -d github.com/googleapis/googleapis
	unset http_proxy
	unset https_proxy
	echo '初始化插件'
	export GO111MODULE=on

	# 基础
	go get -u -v github.com/golang/protobuf/{proto,protoc-gen-go}
	# validate , install
	go get -v -u github.com/envoyproxy/protoc-gen-validate
	# grpc-gateway
	go get -v -u google.golang.org/grpc/cmd/protoc-gen-go-grpc
	go get -v -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger
	go get -v -u github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
	go get -v -u github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	# tag
	go get -v -u github.com/favadi/protoc-go-inject-tag
fi
if [ $1 = "py" ]; then
	python3 -m pip install grpcio       #安装grpc
	python3 -m pip install grpcio-tools #安装grpc tools
	python3 -m pip install grpclib      #安装依赖包
	#生成对应的源码
fi

SEARCH_PATH="-I=. -I=$GOPATH/src -I=$GOPATH/src/github.com/googleapis/googleapis/ -I $GOPATH/src/github.com/envoyproxy/protoc-gen-validate"

install_go() {
	proto=$1
	# grpc
	protoc $SEARCH_PATH --go_out="plugins=grpc,paths=source_relative:." "$proto"

	# validate
	grep "validate.proto" $proto >/dev/null
	if [ $? -eq 0 ]; then
		protoc $SEARCH_PATH --validate_out="lang=go,paths=source_relative:." "$proto"
	fi

	# tag
	pb_path="${proto%.*}.pb.go"
	protoc-go-inject-tag -input="$pb_path"
	yaml="${proto%.*}.yaml"
	if [ -f "$yaml" ]; then
		# grpc-gateway
		protoc $SEARCH_PATH --grpc-gateway_out=paths=source_relative,grpc_api_configuration="$yaml":. "$proto"
	fi
}

install_py() {
	proto=$1
	# 同步调用
	python3 -m grpc_tools.protoc --python_out=. --grpc_python_out=. $SEARCH_PATH $proto
	# 集成async
	# python3 -m grpc_tools.protoc -I. --python_out=. --grpclib_python_out=. $SEARCH_PATH $proto
}

# github.com/googleapis/googleapis
for proto in $(find . | grep '\.proto'); do
	if [ $1 = "go" ]; then
		install_go $proto
	elif [ $1 = "py" ]; then
		install_py $proto
	fi
done
