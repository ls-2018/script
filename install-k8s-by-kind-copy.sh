#! /usr/bin/env zsh
test -e ~/.gopath/bin/kind || {
  curl -LO "https://github.com/kubernetes-sigs/kind/releases/download/v0.17.0/kind-darwin-$(go env GOHOSTARCH)"
  mv kind-darwin-$(go env GOHOSTARCH) ~/.gopath/bin/kind
  chmod +x ~/.gopath/bin/kind
}
test -e ~/.gopath/bin/kubectl || {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(go env GOHOSTARCH)/kubectl"
  # curl -LO "https://dl.k8s.io/release/v1.26.0/bin/linux/$(go env GOHOSTARCH)/kubectl"
  mv kubectl ~/.gopath/bin/kubectl
}

chmod +x ~/.gopath/bin/*

source /etc/profile

kind delete cluster -n=dev

echo 'kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
featureGates:
  "EphemeralContainers": true
nodes:
- role: control-plane
  image: registry.cn-hangzhou.aliyuncs.com/acejilam/node:v1.26.0
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
        certSANs:
          - 127.0.0.1
          - aps-apiserver-svc
' >/tmp/kind.yaml

kind create cluster -n dev --config /tmp/kind.yaml
# kubectl cluster-info --context kind-kind2
