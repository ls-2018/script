#!/usr/bin/env zsh

export VERSION=4.3.0
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

curl -sfL ${GITHUB_PROXY}/https://github.com/labring/sealos/releases/download/v${VERSION}/sealos_${VERSION}_linux_${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/
# sealos reset

if [[ $1 == "cilium" ]]; then
  sealos run registry.cn-hangzhou.aliyuncs.com/acejilam/kubernetes-docker:v1.25.16 \
    registry.cn-hangzhou.aliyuncs.com/acejilam/helm:v3.8.2 \
    --masters 192.168.33.12 --passwd 'root'

  curl -sfL ${GITHUB_PROXY}/https://github.com/cilium/cilium-cli/releases/download/v0.16.5/cilium-linux-${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/
  curl -sfL ${GITHUB_PROXY}/https://github.com/cilium/hubble/releases/download/v1.16.5/hubble-linux-${ARCH}.tar.gz | tar -zxvf - -C /usr/bin/

  cilium install --version 1.16.5
  cilium status --wait
  cilium hubble enable --relay --ui

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

else

  sealos run registry.cn-hangzhou.aliyuncs.com/acejilam/kubernetes-docker:v1.25.16 \
    registry.cn-hangzhou.aliyuncs.com/acejilam/helm:v3.8.2 \
    registry.cn-hangzhou.aliyuncs.com/acejilam/calico:v3.24.1 \
    --masters 192.168.33.12 --passwd 'root'
fi

sed -i "s#apiserver.cluster.local#$(hostname)#g" ~/.kube/config
sed -i "s#kubernetes-admin@kubernetes#$(hostname)#g" ~/.kube/config
cp -rf ~/.kube/config /.host_kube/$(hostname).config
