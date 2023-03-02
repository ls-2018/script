version=1.18

# step 1
open -a "/Applications/Google Chrome.app" https://github.com/protocolbuffers/protobuf/releases
# step 2
go get google.golang.org/protobuf/cmd/protoc-gen-go
# step 3
go get -u google.golang.org/grpc
# step 4
go get google.golang.org/grpc/cmd/protoc-gen-go-grpc

# plugin
go get -u github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway
go get -u github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
go get -u google.golang.org/protobuf/cmd/protoc-gen-go
go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc

protoc --version
protoc-gen-go --version
protoc-gen-go-grpc --version

protoc-gen-grpc-gateway --version
protoc-gen-openapiv2 --version
protoc-gen-go --version
protoc-gen-go-grpc --version
