#!/usr/bin/env zsh
install-k8s-by-kind.sh --name koord --version v1.34.2
cd ~/Desktop
eval "$(print_proxy.py)"
git clone https://github.com/kubeflow/trainer.git -b v1.9.0
unset https_proxy && unset http_proxy && unset all_proxy
kustomize build trainer/manifests/overlays/standalone | kubectl apply --server-side -f -
