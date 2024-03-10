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
  image: kindest/node:VERSION
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
  image: kindest/node:VERSION
  labels:
    node.kubernetes.io/instance-type: controlpanel
    topology.kubernetes.io/zone: zone-a
    node: zone-a
- role: worker
  image: kindest/node:VERSION
  labels:
    topology.kubernetes.io/zone: zone-b
    node: zone-b
- role: worker
  image: kindest/node:VERSION
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
' >/tmp/${name}.yaml

gsed -i "s/VERSION/${version}/g" /tmp/${name}.yaml

kind create cluster --config /tmp/${name}.yaml -n ${name} --kubeconfig ~/.kube/${name}
kubectl cluster-info --context kind-${name} --kubeconfig ~/.kube/${name}
echo 'export KUBECONFIG=~/.kube/koord'
