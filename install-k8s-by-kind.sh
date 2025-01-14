#! /usr/bin/env zsh

test -e ~/.gopath/bin/kubectl || {
  curl -LO "${GITHUB_PROXY}/https://dl.k8s.io/release/$(curl -L -s ${GITHUB_PROXY}/https://dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/$(go env GOHOSTARCH)/kubectl"
  # curl -LO "${GITHUB_PROXY}/https://dl.k8s.io/release/v1.28.0/bin/$(uname |tr '[:upper:]' '[:lower:]')/$(go env GOHOSTARCH)/kubectl"
  mv kubectl ~/.gopath/bin/kubectl
}
# kubectl krew install who-can
# kubectl who-can get secret cluster-admin-creds
# kubectl krew install rakkess

name=${1-kind}
version=${2-v1.28.0}

chmod +x ~/.gopath/bin/*

source /etc/profile

kind delete cluster -n ${name}
mkdir -p /Users/acejilam/data/build_cache
mkdir -p /Users/acejilam/data/plugins/bin

cd /Users/acejilam/data/plugins/bin
test -e /Users/acejilam/data/plugins/bin/bridge || {
  git clone https://github.com/containernetworking/plugins.git -b v1.4.0
  cd plugins
  bash ./build_linux.sh
  mv ./bin/* ../
}

kind create cluster --config ~/script/kind.yaml -n ${name} --kubeconfig ~/.kube/${name} --image registry.cn-hangzhou.aliyuncs.com/acejilam/node:${version}
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

# kubectl --kubeconfig ~/.kube/${name} apply -f https://gitee.com/ls-2018/flannel/raw/master/Documentation/kube-flannel.yml

# 使用示例

echo "export KUBECONFIG=~/.kube/${name}"
