GO111MODULE="on" go install sigs.k8s.io/kind@v0.17.0

kind delete cluster --name dev
cat >/tmp/kind.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# networking:
  # apiServerAddress: "10.10.29.243"
featureGates:
  PodDeletionCost: true
nodes:
- role: control-plane
  # extraPortMappings:
  # - containerPort: 6443
  #   listenAddress: "0.0.0.0"
  #   hostPort: 16443
  #   protocol: TCP
- role: worker
- role: worker
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
    endpoint = [
      "registry.aliyuncs.com/google_containers",
      "https://ccr.ccs.tencentyun.com",
      "https://docker.mirrors.ustc.edu.cn",
      "https://registry.docker-cn.com",
      "http://hub-mirror.c.163.com"
    ]
EOF

kind create cluster --config /tmp/kind.yaml --image kindest/node:v1.26.2 --name dev

kubectl cluster-info --context kind-dev
