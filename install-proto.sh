version=1.18

# step 1
open -a "/Applications/Google Chrome.app" https://github.com/protocolbuffers/protobuf/releases
# step 2
go get -u google.golang.org/protobuf/cmd/protoc-gen-go@latest
# step 3
go get -u google.golang.org/grpc
# step 4
go get -u google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# plugin
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

protoc --version
protoc-gen-go --version
protoc-gen-go-grpc --version

protoc-gen-grpc-gateway --version
protoc-gen-openapiv2 --version
protoc-gen-go --version
protoc-gen-go-grpc --version
