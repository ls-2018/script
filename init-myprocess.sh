#!/usr/bin/env bash
export GOPROXY=""
eval "$(print_proxy.py)"
set -v
go install -v gitee.com/ls-2018/sync/cmd/...@latest
go install -v github.com/lsutils/utils/k8s/cmd/...@latest
