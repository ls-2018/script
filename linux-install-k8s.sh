#!/usr/bin/env zsh
set -x

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

export VERSION=5.0.0
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

cat /resources/tar/${ARCH}/v${VERSION}/sealos_${VERSION}_linux_${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/
# sealos reset

# sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.28.7 \
#   registry.cn-shanghai.aliyuncs.com/labring/helm:v3.14.0 --nodes=192.168.33.12 \
#   --masters=192.168.33.13 \
#   -p=root

sealos run registry.cn-shanghai.aliyuncs.com/labring/kubernetes-docker:v1.28.7 \
	registry.cn-shanghai.aliyuncs.com/labring/helm:v3.14.0 --nodes=192.168.33.12 \
	--masters=192.168.33.13 \
	-p=root

# sealos reset --nodes=192.168.33.12 --masters=192.168.33.13

kubectl taint nodes vm2404 node-role.kubernetes.io/control-plane-

sed -i "s#apiserver.cluster.local#$(hostname)#g" ~/.kube/config
sed -i "s#kubernetes-admin@kubernetes#$(hostname)#g" ~/.kube/config
cp -rf ~/.kube/config /.host_kube/$(hostname).config

scp /tmp/daemon.json root@vm2204:/etc/docker/daemon.json
scp /tmp/daemon.json root@vm2404:/etc/docker/daemon.json

ssh root@vm2204 systemctl daemon-reload
ssh root@vm2404 systemctl daemon-reload
ssh root@vm2204 systemctl restart docker
ssh root@vm2404 systemctl restart docker

cat >/tmp/download.sh <<EOF
  apt install socat -y
  cd /docker_images && ls |xargs -I F docker load -i F
EOF

scp /tmp/download.sh root@vm2204:/tmp/download.sh
ssh root@vm2204 bash /tmp/download.sh
scp /tmp/download.sh root@vm2404:/tmp/download.sh
ssh root@vm2404 bash /tmp/download.sh

cat /resources/tar/${ARCH}/cilium-linux-${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/
cat /resources/tar/${ARCH}/hubble-linux-${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/

helm uninstall tetragon -n kube-system || true
helm uninstall cilium -n kube-system || true
helm install cilium /resources/others/cilium-* \
	-n kube-system \
	--set hubble.ui.enabled=true \
	--set hubble.relay.enabled=true \
	--set hubble.ui.enabled=true \
	--set hubble.ui.standalone.enabled=true \
	--set image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-ci \
	--set certgen.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/certgen \
	--set hubble.relay.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-relay-ci \
	--set hubble.ui.backend.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-ui-backend \
	--set hubble.ui.frontend.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-ui \
	--set envoy.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-envoy \
	--set operator.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/operator \
	--set nodeinit.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/startup-script \
	--set preflight.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-ci \
	--set apiserver.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/clustermesh-apiserver-ci \
	--set authentication.mutual.spire.install.initImage.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/busybox \
	--set authentication.mutual.spire.install.agent.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/spire-agent \
	--set authentication.mutual.spire.install.agent.image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/spire-server \
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

# helm install tetragon /resources/others/tetragon-* -n kube-system
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
cilium status --wait
echo '✅✅✅✅✅✅✅✅✅✅✅✅'

#skopeo copy --all --insecure-policy docker://quay.io/cilium/cilium-envoy:v1.31.5-1737535524-fe8efeb16a7d233bffd05af9ea53599340d3f18e docker://registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-envoy:v1.31.5-1737535524-fe8efeb16a7d233bffd05af9ea53599340d3f18e
#skopeo copy --all --insecure-policy docker://quay.io/cilium/cilium-ci:v1.17.0 docker://registry.cn-hangzhou.aliyuncs.com/acejilam/cilium-ci:v1.17.0
#skopeo copy --all --insecure-policy docker://quay.io/cilium/hubble-relay-ci:v1.17 docker://registry.cn-hangzhou.aliyuncs.com/acejilam/hubble-relay-ci:v1.17.0
