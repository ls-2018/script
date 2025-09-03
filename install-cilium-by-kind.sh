set -x

my_harbor=${1-}

cat >/tmp/kind.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  podSubnet: "10.10.0.0/16"					# default 10.244.0.0/16
  serviceSubnet: "10.11.0.0/16"				# default 10.96.0.0/12
nodes:
- role: control-plane
- role: worker
- role: worker
EOF
kind delete cluster -n cilium

if [[ ${my_harbor} == "harbor" ]]; then
	if [[ "$(docker network ls)" == *harbor* && "$(docker ps -a)" == *harbor-core* ]]; then
		echo "skip"
	else
		docker-install-harbor.sh
	fi
fi

export KUBECONFIG=~/.kube/cilium
kind create cluster -n cilium --kubeconfig ~/.kube/cilium --config /tmp/kind.yaml --image registry.cn-hangzhou.aliyuncs.com/acejilam/node:v1.32.0

eval "$(print_proxy.py)"
test -e /usr/local/bin/cilium || {
	CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
	CLI_ARCH=amd64
	if [ "$(uname -m)" = "arm64" ]; then CLI_ARCH=arm64; fi
	curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
	shasum -a 256 -c cilium-darwin-${CLI_ARCH}.tar.gz.sha256sum
	sudo tar xzvfC cilium-darwin-${CLI_ARCH}.tar.gz /usr/local/bin
	rm cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
}

helm repo add cilium https://helm.cilium.io/ --force-update

if [[ ${my_harbor} == "harbor" ]]; then
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-envoy:v1.34.4-1754895458-68cffdfa568b6b226d70a7ef81fc65dda3b890bf@sha256:247e908700012f7ef56f75908f8c965215c26a27762f296068645eb55450bda2
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/cilium:v1.18.1@sha256:65ab17c052d8758b2ad157ce766285e04173722df59bdee1ea6d5fda7149f0e9
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/operator-generic:v1.18.1@sha256:97f4553afa443465bdfbc1cc4927c93f16ac5d78e4dd2706736e7395382201bc
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-relay:v1.18.1@sha256:7e2fd4877387c7e112689db7c2b153a4d5c77d125b8d50d472dbe81fc1b139b0
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-ui-backend:v0.13.2@sha256:a034b7e98e6ea796ed26df8f4e71f83fc16465a19d166eff67a03b822c0bfa15
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-ui:v0.13.2@sha256:9e37c1296b802830834cc87342a9182ccbb71ffebb711971e849221bd9d59392

	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/json-mock:v1.3.8@sha256:5aad04835eda9025fe4561ad31be77fd55309af8158ca8663a72f6abb78c2603
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/starwars@sha256:896dc536ec505778c03efedb73c3b7b83c8de11e74264c8c35291ff6d5fe8ada
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/k8s-dns-node-cache:1.15.16
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-export-stdout:v1.1.0
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/tetragon:v1.5.0
	trans-image-to-ls-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/tetragon-operator:v1.5.0

	k8s-use-ls-harbor.py
fi

echo "export KUBECONFIG=~/.kube/cilium"

kubectl create namespace cilium-system || true
cilium install \
	--version=v1.18.1 \
	--namespace=cilium-system \
	--set bandwidthManager.enabled=true \
	--set bandwidthManager.bbr=true \
	--set bandwidthManager.bbrHostNamespaceOnly=true \
	--set localRedirectPolicies.enabled=true \
	--set bpf.masquerade=true \
	--set image.pullPolicy=IfNotPresent \
	--set cluster.name=c1 \
	--set debug.enabled=true \
	--set debug.verbose="flow agent envoy daemon monitor kvstore ipam config datapath" \
	--set monitor.enabled=true \
	--set hubble.enabled=true \
	--set hubble.relay.enabled=true \
	--set hubble.relay.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-relay \
	--set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
	--set hubble.ui.enabled=true \
	--set hubble.ui.frontend.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-ui \
	--set hubble.ui.backend.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-ui-backend \
	--set image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium \
	--set envoy.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-envoy \
	--set preflight.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-ci \
	--set operator.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/operator \
	--set preflight.envoy.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-envoy 

helm install tetragon cilium/tetragon \
	-n cilium-system \
	--version v1.5.0 \
	--set tetragon.btf="/sys/kernel/btf/vmlinux" \
	--set tetragon.enableCiliumAPI=false \
	--set tetragon.exportAllowList="" \
	--set tetragon.exportDenyList="" \
	--set tetragon.exportFilename="tetragon.log" \
	--set tetragon.enableProcessCred=true \
	--set tetragon.enableProcessNs=true \
	--set tetragonOperator.enabled=true \
	--set export.stdout.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-export-stdout \
	--set tetragon.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/tetragon \
	--set tetragonOperator.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/tetragon-operator

cilium status --wait -n cilium-system --wait-duration 10m

kubectl apply -f - <<EOF
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: "networking"
spec:
  kprobes:
  - call: "tcp_connect"
    syscall: false
    args:
     - index: 0
       type: "sock"
  - call: "tcp_close"
    syscall: false
    args:
     - index: 0
       type: "sock"
EOF


# 使用示例
curl https://gh-proxy.com/https://raw.githubusercontent.com/cilium/cilium/1.18.1/examples/minikube/http-sw-app.yaml | gsed 's@quay.io/cilium@registry.cn-hangzhou.aliyuncs.com/acejilam@g' | kubectl apply -f -
curl https://gh-proxy.com/https://raw.githubusercontent.com/cilium/cilium/1.18.1/examples/minikube/sw_l3_l4_policy.yaml | kubectl apply -f -

unset https_proxy && unset http_proxy && unset all_proxy

kubectl wait -A --for=condition=Ready pod --all --timeout=300s
# cilium connectivity test

kubectl exec xwing -- curl --max-time 5 -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec tiefighter -- curl --max-time 5 -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing

# cilium-dbg service list
# cilium-dbg endpoint list
# cilium-dbg bpf ipmasq list
# cilium-dbg lrp list
# cilium-dbg policy get
# cilium-dbg monitor -v --type l7
# bpftool net show
