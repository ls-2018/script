set -x

my_harbor=${1-}

cat >/tmp/kind.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  disableDefaultCNI: true
  kubeProxyMode: "none"
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
kind create cluster -n cilium --kubeconfig ~/.kube/cilium --config /tmp/kind.yaml --image $(trans-image-name docker.io/kindest/node:v1.32.0)

eval "$(print_proxy.py)"
test -e /usr/local/bin/cilium || {
	# CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
	CILIUM_CLI_VERSION=v0.18.7
	CLI_ARCH=amd64
	if [ "$(uname -m)" = "arm64" ]; then CLI_ARCH=arm64; fi
	curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
	shasum -a 256 -c cilium-darwin-${CLI_ARCH}.tar.gz.sha256sum
	sudo tar xzvfC cilium-darwin-${CLI_ARCH}.tar.gz /usr/local/bin
	rm cilium-darwin-${CLI_ARCH}.tar.gz{,.sha256sum}
}

helm repo add cilium https://helm.cilium.io/ --force-update

if [[ ${my_harbor} == "harbor" ]]; then
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/cilium-envoy:v1.35.1-1756466197-aecbf661041fc680854fc765e54a283af11db731
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/cilium:v1.19.0-pre.0
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/operator-generic:v1.19.0-pre.0
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/hubble-relay:v1.19.0-pre.0
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/hubble-ui-backend:v0.13.2
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/hubble-ui:v0.13.2
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/json-mock:v1.3.8
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/starwars@sha256:896dc536ec505778c03efedb73c3b7b83c8de11e74264c8c35291ff6d5fe8ada
	trans-image-to-ls-harbor.py --arch all --source registry.k8s.io/dns/k8s-dns-node-cache:1.15.16
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/hubble-export-stdout:v1.1.0
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/tetragon:v1.5.0
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/tetragon-operator:v1.5.0
	trans-image-to-ls-harbor.py --arch all --source quay.io/cilium/cilium_netperf:latest

	k8s-use-ls-harbor.py
fi

echo "export KUBECONFIG=~/.kube/cilium"

kubectl create namespace cilium-system || true

bandwidth="--set bandwidthManager.enabled=true --set bandwidthManager.bbr=true --set bandwidthManager.bbrHostNamespaceOnly=true" # bbr
ipsec="--set encryption.enabled=true --set encryption.type=ipsec"
wireguard="--set encryption.enabled=true --set encryption.type=wireguard  --set encryption.nodeEncryption=true"
# direct_route='--set routing-mode=native --set autoDirectNodeRoutes=true --set ipv4NativeRoutingCIDR=10.0.0.0/8'
direct_route='--set routing-mode=native --set ipv4NativeRoutingCIDR=10.0.0.0/8' # Direct Routing Options
# --set routingMode=tunnel --set tunnelProtocol=vxlan

ebpf="--set bpf.masquerade=true	--set nodePort.enabled=true". # eBPF Host Routing
kubeproxy_replacement="--set kubeProxyReplacement=true"       # 不用安装 kubeproxy

netkit="--set bpf.datapathMode=netkit" # netkit devices need kernel 6.7.0 or newer and CONFIG_NETKIT
socket_lb="--set socketLB.enabled=true"
dsr="--set installNoConntrackIptablesRules=true --set loadBalancer.mode=dsr --set loadBalancer.dsrDispatch=geneve" # DSR Mode
bgp="--set bgpControlPlane.enabled=true --set bgpControlPlane.asNumber=64512 --set k8s.requireIPv4PodCIDR=true"
gateway_api="--set l7Proxy=true --set gatewayAPI.enabled=true"
l7="--set l7Proxy=true"
ingressController="--set ingressController.enabled=true --set ingressController.loadbalancerMode=dedicated" # --set loadBalancer.l7.backend=envoy
egress_gateway="--set devices=eth+ --set egressGateway.enabled=true --set bpf.masquerade=true"
envoy_option="--set envoy.enabled=true"
host_firewall="--set hostFirewall.enabled=true --set devices='{eth0,eth1}'"

# L2 Aware LB(--set l2announcements.enabled=true --set devices='{eth0}' --set externalIPs.enabled=true)
# L2 Pod Announcements Options(--set l2podAnnouncements.enabled=true --set l2podAnnouncements.interface=eth+[which include eth0,eth1,eth2,etc.])
# L2 Aware LB(--set l2announcements.enabled=true --set devices='{eth0, eth1}' --set externalIPs.enabled=true)
# Mutual-Auth Options(--set authentication.mutual.spire.enabled=true --set authentication.mutual.spire.install.enabled=true --set hubble.relay.enabled=true --set hubble.ui.enabled=true)
# Node IPAM LB Options(--set nodeIPAM.enabled=true)
# sctp Options(--set sctp.enabled=true)
# IPv4 BIG TCP Options(--set ipv4.enabled=true --set enableIPv4BIGTCP=true --set bpf.masquerade=true) # not tunnal

kubectl create -n cilium-system secret generic cilium-ipsec-keys \
	--from-literal=keys="3 rfc4543(gcm(aes)) $(echo $(dd if=/dev/urandom count=20 bs=1 2>/dev/null | xxd -p -c 64)) 128"

cilium install \
	--version=v1.19.0-pre.0 \
	--namespace=cilium-system \
	$direct_route \
	$kubeproxy_replacement \
	$ebpf \
	$bandwidth \
	$wireguard \
	$ingressController \
	--set localRedirectPolicies.enabled=true \
	--set image.pullPolicy=IfNotPresent \
	--set monitorAggregation=none \
	--set ipam.mode=kubernetes \
	--set debug.enabled=true \
	--set debug.verbose="flow agent envoy daemon monitor kvstore ipam config datapath" \
	--set monitor.enabled=true \
	--set hubble.enabled=true \
	--set hubble.relay.enabled=true \
	--set hubble.relay.image.repository=$(trans-image-name quay.io/cilium/hubble-relay) \
	--set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
	--set hubble.ui.enabled=true \
	--set hubble.ui.frontend.image.repository=$(trans-image-name quay.io/cilium/hubble-ui) \
	--set hubble.ui.backend.image.repository=$(trans-image-name quay.io/cilium/hubble-ui-backend) \
	--set image.repository=$(trans-image-name quay.io/cilium/cilium) \
	--set envoy.image.repository=$(trans-image-name quay.io/cilium/cilium-envoy) \
	--set preflight.image.repository=$(trans-image-name quay.io/cilium/cilium-ci) \
	--set preflight.envoy.image.repository=$(trans-image-name quay.io/cilium/cilium-envoy) \
	--set operator.image.repository=$(trans-image-name quay.io/cilium/operator)
# --dry-run-helm-values

version='v1.5.0'
tetragon=`trans-image-name quay.io/cilium/tetragon:v1.5.0`
tetragon_repo="${tetragon%%:*}"
tetragon_tag="${tetragon##*:}"

tetragon_operator=`trans-image-name quay.io/cilium/tetragon-operator:v1.5.0`
tetragon_operator_repo="${tetragon%%:*}"
tetragon_operator_tag="${tetragon##*:}"

hubble_export=`trans-image-name quay.io/cilium/hubble-export-stdout:v1.1.0`
hubble_repo="${hubble_export%%:*}"
hubble_tag="${hubble_export##*:}"

helm install tetragon cilium/tetragon \
	-n cilium-system \
	--version ${version} \
	--set tetragon.btf="/sys/kernel/btf/vmlinux" \
	--set tetragon.enableCiliumAPI=false \
	--set tetragon.exportAllowList="" \
	--set tetragon.exportDenyList="" \
	--set tetragon.exportFilename="tetragon.log" \
	--set tetragon.enableProcessCred=true \
	--set tetragon.enableProcessNs=true \
	--set tetragonOperator.enabled=true \
  --set tetragon.image.repository=${tetragon_repo} \
  --set tetragon.image.tag=${tetragon_tag} \
  --set export.stdout.image.repository=${hubble_repo} \
  --set export.stdout.image.tag=${hubble_tag} \
  --set tetragonOperator.image.repository=${tetragon_operator_repo} \
  --set tetragonOperator.image.tag=${tetragon_operator_tag}

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

pref_img=$(trans-image-name quay.io/cilium/netperf)
echo "
apiVersion: v1
kind: Namespace
metadata:
  name: bandwidth
---
apiVersion: v1
kind: Pod
metadata:
  annotations:
    # Limits egress bandwidth to 10Mbit/s.
    kubernetes.io/egress-bandwidth: '10M'
  labels:
    app.kubernetes.io/name: bandwidth-server
  name: bandwidth-server
  namespace: bandwidth
spec:
  containers:
    - name: netperf
      image: ${pref_img}
      ports:
        - containerPort: 12865
---
apiVersion: v1
kind: Service
metadata:
  name: bandwidth-server
  namespace: bandwidth
spec:
  selector:
    app.kubernetes.io/name: bandwidth-server
  ports:
    - protocol: TCP
      port: 12865
      targetPort: 12865
  type: ClusterIP
---
apiVersion: v1
kind: Pod
metadata:
  # This Pod will act as client.
  name: bandwidth-client
  namespace: bandwidth
spec:
  affinity:
    # Prevents the client from being scheduled to the
    # same node as the server.
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - bandwidth-server
          topologyKey: kubernetes.io/hostname
  containers:
    - name: netperf
      command:
        - '/bin/bash'
        - '-c'
        - |
          sleep 2
          netperf -t TCP_MAERTS -H bandwidth-server -p 12865
          sleep 1d
      image: ${pref_img}
" | kubectl apply -f -

# 使用示例
curl -O /tmp/http-sw-app.yaml https://gh-proxy.com/https://raw.githubusercontent.com/cilium/cilium/1.18.1/examples/minikube/http-sw-app.yaml
trans-image-name /tmp/http-sw-app.yaml
kubectl apply -f /tmp/http-sw-app.yaml
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
