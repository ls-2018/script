#!/usr/bin/env bash

export GITHUB_PROXY=""

lines=$(wc -l <"$0")
lines=$(printf "%03d" "$lines")
export PS4='${LINENO}/'"$lines"': '

mkdir -p /Volumes/Tf/resources
cd /Volumes/Tf/resources || exit
# git add . && git reset --hard $(git show-ref --head --hash=8 ... | head -n1)
# git status

rm -rf .git
git init
git add .gitignore
git commit -m "init"

download() {
	set +x
	local url="$2"
	local local_file="$1"
	mkdir -p $(dirname $local_file)

	# 获取本地文件大小（若文件不存在，则大小为 0）
	# local local_size=$(stat -c "%s" "$local_file" 2>/dev/null || echo 0)    linux
	local local_size=$(stat -f "%z" "$local_file" 2>/dev/null || echo 0)
	# 获取远程文件大小
	local remote_size=$(curl -sIL "$url" | tr 'A-Z' 'a-z' | awk '/content-length/ {print $2}' | sed -n '$p' | tr -d '\r')
	echo "$local_size" "$remote_size"
	# 如果大小不同，则下载
	if [[ "$local_size" -ne "$remote_size" ]]; then
		ls -alh "$local_file"
		curl -L --progress-bar -o "$local_file" "$url"
	fi
	set -x
}
set -x

# --no-verbose
export version=$(curl -L -s https://cdn.dl.k8s.io/release/stable.txt)
echo $version

# rm -rf PowerDNS others ssh k8s eunomia-bpf tar .git 3rd yaml

download ./k8s/amd64/kubectl "https://cdn.dl.k8s.io/release/${version}/bin/linux/amd64/kubectl"
download ./k8s/arm64/kubectl "https://cdn.dl.k8s.io/release/${version}/bin/linux/arm64/kubectl"

download ./eunomia-bpf/amd64/ecli ${GITHUB_PROXY}hhttps://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli
download ./eunomia-bpf/amd64/ecc ${GITHUB_PROXY}https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-x86_64

download ./eunomia-bpf/arm64/ecc ${GITHUB_PROXY}https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-aarch64
download ./eunomia-bpf/arm64/ecli ${GITHUB_PROXY}https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli-aarch64

export VERSION=5.0.1
download ./tar/amd64/v${VERSION}/sealos_${VERSION}_linux_amd64.tar.gz https://github.com/labring/sealos/releases/download/v${VERSION}/sealos_${VERSION}_linux_amd64.tar.gz
download ./tar/arm64/v${VERSION}/sealos_${VERSION}_linux_arm64.tar.gz https://github.com/labring/sealos/releases/download/v${VERSION}/sealos_${VERSION}_linux_arm64.tar.gz

download ./tar/amd64/cilium-linux-amd64.tar.gz https://github.com/cilium/cilium-cli/releases/download/v0.16.5/cilium-linux-amd64.tar.gz
download ./tar/arm64/cilium-linux-arm64.tar.gz https://github.com/cilium/cilium-cli/releases/download/v0.16.5/cilium-linux-arm64.tar.gz

download ./tar/amd64/hubble-linux-amd64.tar.gz https://github.com/cilium/hubble/releases/download/v1.16.5/hubble-linux-amd64.tar.gz
download ./tar/arm64/hubble-linux-arm64.tar.gz https://github.com/cilium/hubble/releases/download/v1.16.5/hubble-linux-arm64.tar.gz

download ./tar/amd64/pwru-linux-amd64.tar.gz ${GITHUB_PROXY}https://github.com/cilium/pwru/releases/download/v1.0.9/pwru-linux-amd64.tar.gz
download ./tar/arm64/pwru-linux-arm64.tar.gz ${GITHUB_PROXY}https://github.com/cilium/pwru/releases/download/v1.0.9/pwru-linux-arm64.tar.gz
download ./tar/amd64/retsnoop-v0.10.1-amd64.tar.gz ${GITHUB_PROXY}https://github.com/anakryiko/retsnoop/releases/download/v0.10.1/retsnoop-v0.10.1-amd64.tar.gz
download ./tar/arm64/retsnoop-v0.10.1-arm64.tar.gz ${GITHUB_PROXY}https://github.com/anakryiko/retsnoop/releases/download/v0.10.1/retsnoop-v0.10.1-arm64.tar.gz

download ./tar/amd64/nerdctl-2.0.3-linux-amd64.tar.gz https://github.com/containerd/nerdctl/releases/download/v2.0.3/nerdctl-2.0.3-linux-amd64.tar.gz
download ./tar/arm64/nerdctl-2.0.3-linux-arm64.tar.gz https://github.com/containerd/nerdctl/releases/download/v2.0.3/nerdctl-2.0.3-linux-arm64.tar.gz

export VERSION=1.24.3
download ./tar/arm64/istio-${VERSION}-osx-arm64.tar.gz https://github.com/istio/istio/releases/download/${VERSION}/istio-${VERSION}-osx-arm64.tar.gz
download ./tar/amd64/istio-${VERSION}-osx-amd64.tar.gz https://github.com/istio/istio/releases/download/${VERSION}/istio-${VERSION}-osx-amd64.tar.gz

download ./others/llvm.sh https://mirrors.bfsu.edu.cn/llvm-apt/llvm.sh
download ./others/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key
download ./others/libpcap-1.10.4.tar.gz https://www.tcpdump.org/release/libpcap-1.10.4.tar.gz

download ./PowerDNS https://raw.githubusercontent.com/PowerDNS/pdns/rel/auth-4.2.x/modules/gmysqlbackend/schema.mysql.sql

download ./k8s/amd64/kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/download/v3.9.1/kubebuilder_darwin_amd64
download ./k8s/arm64/kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/download/v3.9.1/kubebuilder_darwin_arm64

download ./yaml/gateway-api/v1.2.0/standard-install.yaml https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml
download ./yaml/metallb/v0.14.9/metallb-frr.yaml https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-frr.yaml
download ./yaml/flannel/v0.26.5/kube-flannel.yml https://raw.githubusercontent.com/flannel-io/flannel/refs/tags/v0.26.5/Documentation/kube-flannel.yml
download ./yaml/flagger/crd.yaml https://raw.githubusercontent.com/fluxcd/flagger/main/artifacts/flagger/crd.yaml
download ./yaml/metrics-server/components.yaml https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.2/components.yaml
download ./yaml/argo-cd/install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
download ./yaml/cert-manager/cert-manager.yaml https://github.com/cert-manager/cert-manager/releases/download/v1.17.2/cert-manager.yaml

mkdir -p ssh
test -e ./ssh/vm1804 || {
	ssh-keygen -t ed25519 -f ./ssh/vm1804 -N "" -C "root@vm1804"
	ssh-keygen -t ed25519 -f ./ssh/vm2004 -N "" -C "root@vm2004"
	ssh-keygen -t ed25519 -f ./ssh/vm2204 -N "" -C "root@vm2204"
	ssh-keygen -t ed25519 -f ./ssh/vm2404 -N "" -C "root@vm2404"
	ssh-keygen -t ed25519 -f ./ssh/ebpf -N "" -C "root@ebpf"
}

cd others
helm repo add cilium https://helm.cilium.io
helm repo update
helm pull cilium/tetragon --version v1.3.0
helm pull cilium/cilium --version 1.17.0
helm pull flagger/flagger --version 1.40.0
cd -

mkdir -p 3rd
git clone https://github.com/brendangregg/perf-tools.git 3rd/perf-tools
git clone https://github.com/iovisor/bcc.git 3rd/bcc
cd 3rd/bcc && git submodule update --init --recursive && cd -
git clone https://github.com/iovisor/bpftrace.git 3rd/bpftrace
git clone https://github.com/libbpf/libbpf.git 3rd/libbpf
git clone https://github.com/retis-org/retis.git 3rd/retis
git clone https://github.com/aya-rs/aya 3rd/aya
git clone https://github.com/fluxcd/flagger 3rd/flagger
git clone https://github.com/torvalds/linux.git -b v6.14 3rd/linux
git clone https://github.com/ohmyzsh/ohmyzsh.git 3rd/ohmyzsh
git clone -b v1.20.0 --depth=1 https://github.com/romkatv/powerlevel10k.git 3rd/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git 3rd/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git 3rd/zsh-syntax-highlighting

download ./tar/arm64/harbor-offline-installer-aarch64-v2.12.2.tgz https://github.com/wise2c-devops/build-harbor-aarch64/releases/download/v2.12.2/harbor-offline-installer-aarch64-v2.12.2.tgz

download "./ttf/MesloLGS NF Regular.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
download "./ttf/MesloLGS NF Bold.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
download "./ttf/MesloLGS NF Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
download "./ttf/MesloLGS NF Bold Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"

download "./sh/p10k.zsh" "https://raw.githubusercontent.com/ls-2018/script/refs/heads/main/.p10k.zsh"
download "./sh/install-zsh.sh" https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
# download "./sh/install-rust.sh" https://sh.rustup.rs
download "./sh/install-rust.sh" https://mirrors.aliyun.com/repo/rust/rustup-init.sh

download ./tar/arm64/gitstatusd-linux-aarch64.tar.gz https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-aarch64.tar.gz
download ./tar/amd64/gitstatusd-linux-x86_64.tar.gz https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-x86_64.tar.gz

chmod-x.sh ./sh

cd 3rd/aya && git submodule update --init --recursive && cd -

# unset https_proxy && unset http_proxy && unset all_proxy

# git config --global init.defaultBranch main

# git lfs install
# git lfs track "*.tar.gz"
# git lfs track "*.tgz"
git add .
git commit -m "$(date)"
# git remote add origin https://gitee.com/ls-2018/resources.git
# git push -u origin "main" --force
