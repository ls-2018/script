#! /usr/bin/env zsh

# kubectl krew install who-can
# kubectl who-can get secret cluster-admin-creds
# kubectl krew install rakkess

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
source "$SCRIPT_DIR/.alias.sh"

name=${1-kind}
version=${2-v1.28.0}
my_harbor=${3-}
nodes=${4-3}

gen-kind-yaml.py $nodes

# if [[ $name == "" ]]; then
# 	echo "Usage: $0 <name> <version>"
# 	exit 1
# fi

# echo '' >~/.kube/${name}

chmod +x ~/.gopath/bin/*

kind delete cluster -n ${name}
set -e

mkdir -p /Volumes/Tf/data/build_cache
mkdir -p /Volumes/Tf/data/plugins/bin

if test -d "/Volumes/Tf/data/kind"; then
	rm -rf /Volumes/Tf/data/kind/*
fi

mkdir -p /Volumes/Tf/data/kind/logs

cd /Volumes/Tf/data/plugins/bin
test -e /Volumes/Tf/data/plugins/bin/bridge || {
	company_proxy
	git clone https://github.com/containernetworking/plugins.git -b v1.4.0
	unset https_proxy && unset http_proxy && unset all_proxy
	cd plugins
	bash ./build_linux.sh
	mv ./bin/* ../
}
node_img=$(trans_image_name.py docker.io/kindest/node:${version})
kind create cluster --config /tmp/gen-kind.yaml -n ${name} --kubeconfig ~/.kube/kind-${name} --image ${node_img}
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

{
	echo "export KUBECONFIG=~/.kube/kind-${name}"
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
