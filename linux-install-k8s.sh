#!/usr/bin/env zsh

export VERSION=4.3.0
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

curl -sfL https://cf.ghproxy.cc/https://github.com/labring/sealos/releases/download/v${VERSION}/sealos_${VERSION}_linux_${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/
# sealos reset

sealos run registry.cn-hangzhou.aliyuncs.com/acejilam/kubernetes-docker:v1.25.16 \
    registry.cn-hangzhou.aliyuncs.com/acejilam/helm:v3.8.2 \
    registry.cn-hangzhou.aliyuncs.com/acejilam/calico:v3.24.1
