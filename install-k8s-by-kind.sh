#! /usr/bin/env zsh
# kubectl krew install who-can
# kubectl who-can get secret cluster-admin-creds
# kubectl krew install rakkess
. /Users/acejilam/script/alias.sh

name=${1-kind}
version=${2-v1.28.0}
my_harbor=${3-}
# if [[ $name == "" ]]; then
# 	echo "Usage: $0 <name> <version>"
# 	exit 1
# fi

# echo '' >~/.kube/${name}

chmod +x ~/.gopath/bin/*

kind delete cluster -n ${name}
set -e

mkdir -p /Users/acejilam/data/build_cache
mkdir -p /Users/acejilam/data/plugins/bin

if test -d "/Users/acejilam/data/kind"; then
	rm -rf /Users/acejilam/data/kind/*
fi

mkdir -p /Users/acejilam/data/kind/logs

cd /Users/acejilam/data/plugins/bin
test -e /Users/acejilam/data/plugins/bin/bridge || {
	company_proxy
	git clone https://github.com/containernetworking/plugins.git -b v1.4.0
	unset https_proxy && unset http_proxy && unset all_proxy
	cd plugins
	bash ./build_linux.sh
	mv ./bin/* ../
}

kind create cluster --config ~/script/kind.yaml -n ${name} --kubeconfig ~/.kube/kind-${name} --image registry.cn-hangzhou.aliyuncs.com/acejilam/node:${version}
kubectl cluster-info --context kind-${name} --kubeconfig ~/.kube/kind-${name}

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
# cp /Volumes/Tf/resources/yaml/flannel/v0.26.5/kube-flannel.yml /tmp/kube-flannel.yml
# sed -i 's@ghcr.io/flannel-io@registry.cn-hangzhou.aliyuncs.com/acejilam@g' /tmp/kube-flannel.yml

# kubectl --kubeconfig ~/.kube/${name} apply -f /tmp/kube-flannel.yml

# 使用示例

# gsed -i "s@kind-@@g" ~/.kube/${name}

echo "export KUBECONFIG=~/.kube/kind-${name}"
{
	# cp ~/.kube/${name} ~/.kube/kind-${name}-node

	# export CIP=`docker inspect koord-control-plane|jq '.[0].NetworkSettings.Networks.kind.IPAddress' | tr -d "\"'"`
	#yq -i '.clusters[0].cluster.server = "https://" + env(CIP) + ":6443"' ~/.kube/${name}-node

	# export CIP="${name}-control-plane"
	# yq -i '.clusters[0].cluster.server = "https://" + env(CIP) + ":6443"' ~/.kube/${name}-node
}
rm -rf ./nerdctl
mkdir ./nerdctl
export KUBECONFIG=~/.kube/kind-${name}
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
cat /Volumes/Tf/resources/tar/${ARCH}/nerdctl-2.0.3-linux-${ARCH}.tar.gz | tar -zxvf - -C ./nerdctl

kubectl get nodes | awk -F ' ' '{print $1}' | grep -v NAME | xargs -I F docker cp ./nerdctl/nerdctl F:/usr/bin/

rm -rf ./nerdctl

if [[ ${my_harbor} == "harbor" ]]; then
	if [[ "$(docker network ls)" == *harbor* && "$(docker ps -a)" == *harbor-core* ]]; then
		echo "skip"
		# docker-compose -f $(docker-compose ls --format json | jq -r '.[] | select(.Name == "harbor") | .ConfigFiles') restart
	else
		docker-install-harbor.sh
	fi

	k8s-use-ls-harbor.py
fi
