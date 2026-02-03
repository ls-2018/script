#!/usr/bin/env zsh

# kubectl krew install who-can
# kubectl who-can get secret cluster-admin-creds
# kubectl krew install rakkess

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
source "$SCRIPT_DIR/.customer_script.sh"

# 解析命令行参数
name="koord"
version="v1.34.2"
my_harbor=""
nodes=3

while [[ $# -gt 0 ]]; do
	case $1 in
	--name)
		name="$2"
		shift
		shift
		;;
	--version)
		version="$2"
		shift
		shift
		;;
	--harbor)
		my_harbor="harbor"
		shift
		;;
	--nodes)
		nodes="$2"
		shift
		shift
		;;
	*)
		echo "未知参数: $1"
		echo "用法: $0 [--name <cluster-name>] [--version <k8s-version>] [--harbor] [--nodes <node-count>]"
		exit 1
		;;
	esac
done

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

node_img=$(trans-image-name docker.io/kindest/node:${version})
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

# rm /tmp/kube-flannel.yml
# cp /Volumes/Tf/resources/yaml/flannel/v0.26.5/kube-flannel.yml /tmp/kube-flannel.yml
# trans-image-name /tmp/kube-flannel.yml

# kubectl --kubeconfig ~/.kube/${name} apply -f /tmp/kube-flannel.yml

# 使用示例

# gsed -i "s@kind-@@g" ~/.kube/${name}

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
		$SCRIPT_DIR/docker-install-harbor.sh
	fi

	$SCRIPT_DIR/k8s-use-ls-harbor.py
fi
ip=$(python3 -c'from print_proxy import *;print(get_ip())')

gsed -i "s@127.0.0.1@${ip}@g" ~/.kube/kind-${name}
