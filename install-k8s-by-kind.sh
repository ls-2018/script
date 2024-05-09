#! /usr/bin/env zsh

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
mkdir -p /Users/acejilam/data/build_cache
mkdir -p /Users/acejilam/data/plugins/bin

cd /Users/acejilam/data/plugins/bin
test -e /Users/acejilam/data/plugins/bin/bridge || {
  git clone https://github.com/containernetworking/plugins.git
  cd plugins
  bash ./build_linux.sh
  mv ./bin/* ../
}

echo 'kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  # the default CNI will not be installed
  #disableDefaultCNI: true
# featureGates:
  # "EphemeralContainers": true
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
        certSANs:
          - 192.168.153.129
          - 192.168.113.128
          - 10.230.205.190
          - 127.0.0.1
          - localhost
  extraPortMappings:
  - containerPort: 6443
    hostPort: 6443
    protocol: TCP
  extraMounts:
  # - hostPath: /Users/acejilam/data/plugins/bin
  #   containerPath: /opt/cni/bin
  - hostPath: /Users/acejilam/data/nfs
    containerPath: /nfs
- role: worker
  labels:
    node.kubernetes.io/instance-type: controlpanel
    topology.kubernetes.io/zone: zone-a
    nfs: true
    node: zone-a
  extraMounts:
  # - hostPath: /Users/acejilam/data/plugins/bin
    # containerPath: /opt/cni/bin
  - hostPath: /Users/acejilam/data/build_cache
    containerPath: /tmp/build_cache
  - hostPath: /Users/acejilam/data/nfs
    containerPath: /nfs
# - role: worker
#   labels:
#     topology.kubernetes.io/zone: zone-b
#     node: zone-b
#   extraMounts:
#   - hostPath: /Users/acejilam/data/plugins/bin
#     containerPath: /opt/cni/bin
#   - hostPath: /Users/acejilam/data/build_cache
#     containerPath: /tmp/build_cache
#   - hostPath: /Users/acejilam/data/nfs
#     containerPath: /nfs
# - role: worker
#   labels:
#     topology.kubernetes.io/zone: zone-c
#     node: zone-c
#   extraMounts:
#   - hostPath: /Users/acejilam/data/plugins/bin
#     containerPath: /opt/cni/bin
#   - hostPath: /Users/acejilam/data/build_cache
#     containerPath: /tmp/build_cache
#   - hostPath: /Users/acejilam/data/nfs
#     containerPath: /nfs
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

curl -o /tmp/kube-flannel.yml https://gitee.com/ls-2018/flannel/raw/master/Documentation/kube-flannel.yml

# perl -pe 's/docker.io/docker.m.daocloud.io/g' /tmp/kube-flannel.yml | kubectl apply --kubeconfig ~/.kube/${name} -f -

# 使用示例

echo "export KUBECONFIG=~/.kube/${name}"
