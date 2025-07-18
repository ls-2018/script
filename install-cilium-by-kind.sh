cat >/tmp/kind.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
nodes:
- role: control-plane
- role: worker
- role: worker
- role: worker
EOF
kind delete cluster -n cilium
kind create cluster -n cilium --kubeconfig ~/.kube/cilium --config /tmp/kind.yaml --image registry.cn-hangzhou.aliyuncs.com/acejilam/node:v1.25.2
# 使用示例

test -e /usr/local/bin/cilium || {
	CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
	CLI_ARCH=amd64
	if [ "$(uname -m)" = "arm64" ]; then CLI_ARCH=arm64; fi
	curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
	shasum -a 256 -c cilium-darwin-${CLI_ARCH}.tar.gz.sha256sum
	sudo tar xzvfC cilium-darwin-${CLI_ARCH}.tar.gz /usr/local/bin
	rm cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
}

echo "export KUBECONFIG=~/.kube/cilium"

export KUBECONFIG=~/.kube/cilium
cilium install --version 1.16.0
