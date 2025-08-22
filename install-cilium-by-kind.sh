set -x

my_harbor=${1-}

cat >/tmp/kind.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
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
kind create cluster -n cilium --kubeconfig ~/.kube/cilium --config /tmp/kind.yaml --image registry.cn-hangzhou.aliyuncs.com/acejilam/node:v1.30.3

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
	trans-image-to-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-envoy:v1.34.4-1754895458-68cffdfa568b6b226d70a7ef81fc65dda3b890bf@sha256:247e908700012f7ef56f75908f8c965215c26a27762f296068645eb55450bda2
	trans-image-to-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/cilium:v1.18.1@sha256:65ab17c052d8758b2ad157ce766285e04173722df59bdee1ea6d5fda7149f0e9
	trans-image-to-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/operator-generic:v1.18.1@sha256:97f4553afa443465bdfbc1cc4927c93f16ac5d78e4dd2706736e7395382201bc
	trans-image-to-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/json-mock:v1.3.8@sha256:5aad04835eda9025fe4561ad31be77fd55309af8158ca8663a72f6abb78c2603
	trans-image-to-harbor.py registry.cn-hangzhou.aliyuncs.com/acejilam/starwars@sha256:896dc536ec505778c03efedb73c3b7b83c8de11e74264c8c35291ff6d5fe8ada
	k8s-use-ls-harbor.py
fi

# 使用示例
curl https://raw.githubusercontent.com/cilium/cilium/1.18.1/examples/minikube/http-sw-app.yaml | gsed 's@quay.io/cilium@registry.cn-hangzhou.aliyuncs.com/acejilam@g' | kubectl apply -f -
echo "export KUBECONFIG=~/.kube/cilium"

kubectl create namespace cilium-system || true
cilium install \
	--version=v1.18.1 \
	--namespace=cilium-system \
	--set image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium \
	--set envoy.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-envoy \
	--set preflight.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-ci \
	--set operator.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/operator \
	--set preflight.envoy.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-envoy

unset https_proxy && unset http_proxy && unset all_proxy

cilium status --wait -n cilium-system --wait-duration 10m

# cilium connectivity test

kubectl exec xwing -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
kubectl exec tiefighter -- curl -s -XPOST deathstar.default.svc.cluster.local/v1/request-landing
