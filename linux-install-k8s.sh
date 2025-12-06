#!/usr/bin/env bash

set -ex

cat >/tmp/daemon.json <<EOF
{
  "max-concurrent-downloads": 20,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "insecure-registries": [
    "sealos.hub:5000"
  ],
  "data-root": "/var/lib/docker",
  "registry-mirrors": [
    "https://docker.211678.top",
    "https://docker.1panel.live",
    "https://hub.rat.dev",
    "https://docker.m.daocloud.io",
    "https://do.nark.eu.org",
    "https://dockerpull.com",
    "https://dockerproxy.cn",
    "https://docker.awsl9527.cn"
  ]
}
EOF

export VERSION=5.0.1
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

cat /Volumes/Tf/resources/tar/${ARCH}/v${VERSION}/sealos_${VERSION}_linux_${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/
cat /Volumes/Tf/resources/tar/${ARCH}/cilium-linux-${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/
cat /Volumes/Tf/resources/tar/${ARCH}/hubble-linux-${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/

# sealos reset

\ping registry.cn-shanghai.aliyuncs.com -c 4

parse_ip() {
	cat /etc/hosts | grep $1 | awk -F ' ' '{print $1}' | head -n 1
}
nodes_Str=""
hosts=("vm2404" "vm1804" "vm2004" "vm2204")

worker_hosts=("${hosts[@]:1}")
for host in "${worker_hosts[@]}"; do
	echo "Checking Worker $host..."
	if ping -c 1 -W 1 "$host" &>/dev/null; then
		nodes_Str+=$(parse_ip "$host"),
	fi
done
nodes_Str=${nodes_Str%,}

if test -d "/docker_images/sealos"; then
	ls /docker_images/sealos | xargs -I F sealos load -i /docker_images/sealos/F
fi

sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.30.3 \
	registry.cn-shanghai.aliyuncs.com/labring/helm:v3.14.0 \
	--nodes=${nodes_Str} \
	--masters=$(parse_ip vm2404) \
	-p=root

kubectl label node vm2004 nfs=true
kubectl taint nodes vm2404 node-role.kubernetes.io/control-plane-

sed -i "s#apiserver.cluster.local#$(hostname)#g" ~/.kube/config
sed -i "s#kubernetes-admin@kubernetes#$(hostname)#g" ~/.kube/config
cp -rf ~/.kube/config /host_kube/$(hostname).config

cat >/tmp/download.sh <<EOF
  export DEBIAN_FRONTEND=noninteractive
  apt install socat net-tools nfs-common -y
  cd /docker_images && ls | grep tar |xargs -I F docker load -i F
EOF

for host in "${hosts[@]}"; do
	echo "Checking $host..."
	if ping -c 1 -W 1 "$host" &>/dev/null; then
		scp /tmp/daemon.json root@${host}:/etc/docker/daemon.json
		ssh root@${host} systemctl daemon-reload
		ssh root@${host} systemctl restart docker
		scp /tmp/download.sh root@${host}:/tmp/download.sh
		ssh root@${host} bash /tmp/download.sh
	fi
done

if helm list -n kube-system | grep -q "tetragon"; then
	helm uninstall tetragon -n kube-system
fi

if helm list -n kube-system | grep -q "tetrciliumagon"; then
	helm uninstall cilium -n kube-system
fi

helm install cilium /Volumes/Tf/resources/others/cilium-* \
	-n kube-system \
	--set hubble.ui.enabled=true \
	--set hubble.relay.enabled=true \
	--set hubble.ui.enabled=true \
	--set hubble.ui.standalone.enabled=true \
	--set image.repository=$(trans_image_name.py docker.io/cilium/cilium-ci) \
	--set certgen.image.repository=$(trans_image_name.py docker.io/cilium/certgen) \
	--set hubble.relay.image.repository=$(trans_image_name.py docker.io/cilium/hubble-relay-ci) \
	--set hubble.ui.backend.image.repository=$(trans_image_name.py docker.io/cilium/hubble-ui-backend) \
	--set hubble.ui.frontend.image.repository=$(trans_image_name.py docker.io/cilium/hubble-ui) \
	--set envoy.image.repository=$(trans_image_name.py docker.io/cilium/cilium-envoy) \
	--set operator.image.repository=$(trans_image_name.py docker.io/cilium/operator) \
	--set nodeinit.image.repository=$(trans_image_name.py docker.io/cilium/startup-script) \
	--set preflight.image.repository=$(trans_image_name.py docker.io/cilium/cilium-ci) \
	--set apiserver.image.repository=$(trans_image_name.py docker.io/cilium/clustermesh-apiserver) \
	--set authentication.mutual.spire.install.initImage.repository=$(trans_image_name.py docker.io/library/busybox) \
	--set authentication.mutual.spire.install.agent.image.repository=$(trans_image_name.py ghcr.io/spiffe/spire-agent) \
	--set authentication.mutual.spire.install.agent.image.repository=$(trans_image_name.py ghcr.io/spiffe/spire-server) \
	--set image.useDigest=false \
	--set certgen.image.useDigest=false \
	--set hubble.relay.image.useDigest=false \
	--set hubble.ui.backend.image.useDigest=false \
	--set hubble.ui.frontend.image.useDigest=false \
	--set envoy.image.useDigest=false \
	--set operator.image.useDigest=false \
	--set nodeinit.image.useDigest=false \
	--set preflight.image.useDigest=false \
	--set apiserver.image.useDigest=false \
	--set authentication.mutual.spire.install.initImage.useDigest=false \
	--set authentication.mutual.spire.install.agent.image.useDigest=false \
	--set authentication.mutual.spire.install.server.image.useDigest=false

# helm install tetragon /Volumes/Tf/resources/others/tetragon-* -n kube-system
# cilium hubble enable --relay --ui

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: hubble-ui-node
  namespace: kube-system
spec:
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 8081
      nodePort: 30081
  selector:
    k8s-app: hubble-ui
  type: NodePort
EOF
echo '✅✅✅✅✅✅✅✅✅✅✅✅'
cilium status
