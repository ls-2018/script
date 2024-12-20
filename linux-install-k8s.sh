#!/usr/bin/env zsh

export VERSION=v4.3.0
curl -sfL https://cf.ghproxy.cc/https://raw.githubusercontent.com/labring/sealos/${VERSION}/scripts/install.sh | sh -s ${VERSION} labring/sealos
unset https_proxy

rm -rf ~/.sealos/
# sealos reset

sealos run registry.cn-hangzhou.aliyuncs.com/acejilam/kubernetes-docker:v1.25.16 \
    registry.cn-hangzhou.aliyuncs.com/acejilam/helm:v3.8.2 \
    registry.cn-hangzhou.aliyuncs.com/acejilam/calico:v3.24.1
