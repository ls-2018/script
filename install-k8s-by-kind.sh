#! /usr/bin/env zsh

# kubectl krew install who-can
# kubectl who-can get secret cluster-admin-creds
# kubectl krew install rakkess

name=${1-kind}
version=${2-v1.28.0}

chmod +x ~/.gopath/bin/*

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

# rm /tmp/kube-flannel.yml
# cp ~/resources/yaml/flannel/v0.26.5/kube-flannel.yml /tmp/kube-flannel.yml
# gsed -i 's@ghcr.io/flannel-io@registry.cn-hangzhou.aliyuncs.com/acejilam@g' /tmp/kube-flannel.yml

# kubectl --kubeconfig ~/.kube/${name} apply -f /tmp/kube-flannel.yml

# 使用示例

echo "export KUBECONFIG=~/.kube/${name}"

cp ~/.kube/${name} ~/.kube/${name}-node

# export CIP=`docker inspect koord-control-plane|jq '.[0].NetworkSettings.Networks.kind.IPAddress' | tr -d "\"'"`

#yq -i '.clusters[0].cluster.server = "https://" + env(CIP) + ":6443"' ~/.kube/${name}-node
export CIP="${name}-control-plane"
yq -i '.clusters[0].cluster.server = "https://" + env(CIP) + ":6443"' ~/.kube/${name}-node

rm -rf /tmp/nerdctl
mkdir /tmp/nerdctl

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
cat ~/resources/tar/${ARCH}/nerdctl-2.0.3-linux-${ARCH}.tar.gz | tar -zxvf - -C /tmp/nerdctl

kubectl get nodes | awk -F ' ' '{print $1}' | grep -v NAME | xargs -I F docker cp /tmp/nerdctl/nerdctl F:/usr/bin/
