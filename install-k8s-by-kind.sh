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

kind delete cluster
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
    # apiServer:
    #     certSANs:
    #       - 127.0.0.1
    #       - 192.168.31.239
    #       - 192.168.153.129
  extraPortMappings:
  - containerPort: 6443
    hostPort: 6443
    protocol: TCP
- role: worker
  image: registry.cn-hangzhou.aliyuncs.com/acejilam/node:v1.26.0
kubeadmConfigPatches:
  - |
    apiVersion: kubeadm.k8s.io/v1beta2
    kind: ClusterConfiguration
    etcd:
      local:
        dataDir: /tmp/etcd # /tmp directory is a tmpfs(in memory),use it for speeding up etcd and lower disk IO.
' >/tmp/kind.yaml

kind create cluster --config /tmp/kind.yaml
kubectl cluster-info --context kind-kind
