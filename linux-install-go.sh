#!/usr/bin/env zsh

set -ex

rm -rf /usr/local/go*
rm -rf ./go*
yum install wget vim gcc -y || apt install wget vim gcc -y

version=1.22.0
mkdir /usr/local/go$version

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

wget https://golang.google.cn/dl/go$version.linux-$ARCH.tar.gz
tar -xvf go$version.linux-$ARCH.tar.gz -C /usr/local/go$version --strip-components 1
rm -rf go$version.linux-$ARCH.tar.gz
mkdir -p ~/.gopath/{bin,src,pkg}
chmod -R 777 /usr/local/go$version
cat <<EOF >>/etc/profile
export GOROOT="/usr/local/go$version"
export GOPATH=\$HOME/.gopath  #工作地址路径
export GOBIN=\$GOROOT/bin
export PATH=\$PATH:\$GOBIN
EOF

cat <<EOF >>~/.bashrc
export GOROOT="/usr/local/go$version"
export GOPATH=\$HOME/.gopath  #工作地址路径
export GOBIN=\$GOROOT/bin
export PATH=\$PATH:\$GOBIN
EOF

source /etc/profile
go version
go env
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GOFLAGS="-buildvcs=false"
go env -w CGO_ENABLED="1"

go install github.com/trzsz/trzsz-go/cmd/...@latest
go install github.com/go-delve/delve/cmd/dlv@latest
