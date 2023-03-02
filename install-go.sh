version=1.18

rm -rf /usr/local/go*
yum install wget vim -y
wget https://golang.google.cn/dl/go$version.linux-amd64.tar.gz
mkdir /usr/local/go$version
tar -xvf go$version.linux-amd64.tar.gz -C /usr/local/go$version --strip-components 1

mkdir -p ~/go/{bin,src,pkg}

cat <<EOF >>/etc/profile

export GOROOT="/usr/local/go$version"
export GOPATH=\$HOME/go  #工作地址路径
export GOBIN=\$GOROOT/bin
export PATH=\$PATH:\$GOBIN
EOF
source /etc/profile
go version
go env
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
