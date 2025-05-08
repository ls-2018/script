#!/usr/bin/env python3
#
import os
import sys

install_go = '''
set -ex
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go${VERSION}/bin
mkdir /usr/local/go${VERSION}

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

wget https://golang.google.cn/dl/go${VERSION}.linux-$ARCH.tar.gz
tar -xvf go${VERSION}.linux-$ARCH.tar.gz -C /usr/local/go${VERSION} --strip-components 1
rm -rf go${VERSION}.linux-$ARCH.tar.gz
mkdir -p /root/.gopath/{bin,src,pkg}
chmod -R 777 /usr/local/go${VERSION}

go version
go env

'''

install_go_bin ='''
go install github.com/trzsz/trzsz-go/cmd/...@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/rakyll/hey@latest
'''

install_bin ='''
apt install vim wget curl make cmake -y
'''


dockerfile = '''
FROM registry.cn-hangzhou.aliyuncs.com/acejilam/ubuntu:24.04
WORKDIR /
ENV CGO_ENABLED="1"
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
ENV GOROOT=/usr/local/go${VERSION}
ENV GOPATH=/root/.gopath
ENV GOBIN=/usr/local/go${VERSION}/bin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go${VERSION}/bin
RUN rm -rf /usr/local/go* || echo 1
RUN rm -rf ./go*  		  || echo 1
RUN rm -rf /etc/apt/sources.list.d/gierens.list
RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
  sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/* && \
  sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
  sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/* && \
  sed -i "s@http://.*ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
  sed -i "s@http://.*ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*
RUN apt update -y && apt install wget git gcc curl -y
RUN	ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl" && \
	chmod +x kubectl && \
	mv kubectl /usr/local/bin/kubectl

COPY ./install_go.sh /tmp/install_go.sh
RUN bash /tmp/install_go.sh

COPY ./install_bin.sh /tmp/install_bin.sh
RUN bash /tmp/install_bin.sh

COPY ./install_go_bin.sh /tmp/install_go_bin.sh
RUN bash /tmp/install_go_bin.sh

'''

print('docker buildx create --use --name mygo')
try:
    os.mkdir('/tmp/gobuild')
except:
    pass
version = sys.argv[1].strip('v ')
repo = sys.argv[2].strip('')

print(version)

with open('/tmp/gobuild/.dockerignore', 'w', encoding='utf-8') as file:
    file.write('Dockerfile')
with open('/tmp/gobuild/install_go.sh', 'w', encoding='utf-8') as file:
    file.write(install_go.replace('${VERSION}', version))

with open('/tmp/gobuild/install_bin.sh', 'w', encoding='utf-8') as file:
    file.write(install_bin)

with open('/tmp/gobuild/install_go_bin.sh', 'w', encoding='utf-8') as file:
    file.write(install_go_bin)

with open('/tmp/gobuild/Dockerfile', 'w', encoding='utf-8') as file:
    file.write(dockerfile.replace('${VERSION}', version))

os.system('cd /tmp/gobuild && ' + \
          f'docker buildx build --platform linux/arm64,linux/amd64 --pull -t {repo}/mygo:v{version} --push . ')
print(f'{repo}/mygo:v{version}')
