#!/usr/bin/env zsh
install-k8s-by-kind.sh --name koord --version v1.34.0
cd ~/Desktop
git clone https://github.com/kubeflow/trainer.git -b v1.9.0
kustomize build trainer/manifests/overlays/standalone | kubectl apply --server-side -f -
