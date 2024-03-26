#! /usr/bin/env zsh

test -e ~/.gopath/bin/kind || {
  curl -LO "https://github.com/kubernetes-sigs/kind/releases/download/v0.17.0/kind-$(uname | tr '[:upper:]' '[:lower:]')-$(go env GOHOSTARCH)"
  mv kind-darwin-$(go env GOHOSTARCH) ~/.gopath/bin/kind
  chmod +x ~/.gopath/bin/kind
}
test -e ~/.gopath/bin/kubectl || {
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/$(go env GOHOSTARCH)/kubectl"
  # curl -LO "https://dl.k8s.io/release/v1.24.15/bin/$(uname |tr '[:upper:]' '[:lower:]')/$(go env GOHOSTARCH)/kubectl"
  mv kubectl ~/.gopath/bin/kubectl
}

name=${1-kind}
version=${2-v1.24.15}

chmod +x ~/.gopath/bin/*

source /etc/profile

kind delete cluster -n ${name}

echo 'kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# featureGates:
  # "EphemeralContainers": true
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    # apiServer:
    #     certSANs:
    #       - 192.168.153.129
  # extraPortMappings:
  # - containerPort: 6443
  #   hostPort: 6443
  #   protocol: TCP
- role: worker
  labels:
    node.kubernetes.io/instance-type: controlpanel
    topology.kubernetes.io/zone: zone-a
    node: zone-a
- role: worker
  labels:
    topology.kubernetes.io/zone: zone-b
    node: zone-b
- role: worker
  labels:
    topology.kubernetes.io/zone: zone-c
    node: zone-c
# kubeadmConfigPatches:
#   - |
#     apiVersion: kubeadm.k8s.io/v1beta2
#     kind: ClusterConfiguration
#     etcd:
#       local:
#         dataDir: /tmp/etcd # /tmp directory is a tmpfs(in memory),use it for speeding up etcd and lower disk IO.
    # apiServer:
    #   extraArgs:
    #     enable-admission-plugins: OwnerReferencesPermissionEnforcement,PodNodeSelector,PodTolerationRestriction,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook

kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        "cgroup-root": "/"
    ---
    kind: KubeletConfiguration
    cgroupRoot: /

' >/tmp/${name}.yaml

gsed -i "s/VERSION/${version}/g" /tmp/${name}.yaml

kind create cluster --config /tmp/${name}.yaml -n ${name} --kubeconfig ~/.kube/${name} --image m.daocloud.io/docker.io/kindest/node:${version}
kubectl cluster-info --context kind-${name} --kubeconfig ~/.kube/${name}
string_contains() {
  local str=$1
  local sub_str=$2
  if [[ $str == *"$sub_str"* ]]; then
    return 0
  else
    return 1
  fi
}

# 使用示例

if string_contains ${name} "koord"; then
  # docker pull registry.cn-beijing.aliyuncs.com/koordinator-sh/koord-manager:v1.4.0
  # docker pull registry.cn-beijing.aliyuncs.com/koordinator-sh/koordlet:v1.4.0
  # docker pull registry.cn-beijing.aliyuncs.com/koordinator-sh/koord-scheduler:v1.4.0
  # docker pull registry.cn-beijing.aliyuncs.com/koordinator-sh/koord-descheduler:v1.4.0

  # kind load docker-image -n ${name} registry.cn-beijing.aliyuncs.com/koordinator-sh/koord-manager:v1.4.0
  # kind load docker-image -n ${name} registry.cn-beijing.aliyuncs.com/koordinator-sh/koordlet:v1.4.0
  # kind load docker-image -n ${name} registry.cn-beijing.aliyuncs.com/koordinator-sh/koord-scheduler:v1.4.0
  # kind load docker-image -n ${name} registry.cn-beijing.aliyuncs.com/koordinator-sh/koord-descheduler:v1.4.0

fi

if string_contains ${name} "kruise"; then
  docker pull openkruise/kruise-manager:v1.4.0
  kind load docker-image -n ${name} openkruise/kruise-manager:v1.4.0
  kind load docker-image -n ${name} centos:7
  kind load docker-image -n ${name} registry.cn-hangzhou.aliyuncs.com/acejilam/mygo:v1.21.5
fi

echo "export KUBECONFIG=~/.kube/${name}"
