#!/usr/bin/env bash
rm -rf /usr/local/go*
rm -rf ./go*
apt install wget vim gcc -y

apt install musl musl-tools musl-dev -y

version=$(curl -s https://golang.google.cn/dl/ | grep -oP 'go\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | uniq | tail -n 1)
mkdir /usr/local/go$version

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

wget --no-verbose https://golang.google.cn/dl/go$version.linux-$ARCH.tar.gz
tar -xf go$version.linux-$ARCH.tar.gz -C /usr/local/go$version --strip-components 1
rm -rf go$version.linux-$ARCH.tar.gz
mkdir -p ~/.gopath/{bin,src,pkg}
chmod -R 777 /usr/local/go$version

export GOROOT="/usr/local/go$version"
export GOPATH=$HOME/.gopath #工作地址路径
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

go version
go env
# go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
# go env -w GOFLAGS="-buildvcs=false"
# go env -w CGO_ENABLED="1"

go install github.com/trzsz/trzsz-go/cmd/trz@latest
go install github.com/trzsz/trzsz-go/cmd/tsz@latest
go install github.com/trzsz/trzsz-go/cmd/trzsz@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/google/gops@latest

echo """
export GOROOT=/usr/local/go$version
export GOPATH=$HOME/.gopath 
export PATH=$PATH:/usr/local/go$version/bin:$HOME/.gopath/bin
""" >> ~/.bashrc