cat <<EOF >/tmp/node.yaml
apiVersion: v1
kind: Node
metadata:
  annotations:
    node.alpha.kubernetes.io/ttl: "0"
    kwok.x-k8s.io/node: fake
  labels:
    beta.kubernetes.io/arch: amd64
    beta.kubernetes.io/os: linux
    kubernetes.io/arch: amd64
    kubernetes.io/hostname: {NODE_NAME}
    kubernetes.io/os: linux
    kubernetes.io/role: agent
    node-role.kubernetes.io/agent: ""
    type: kwok
  name: {NODE_NAME}
spec:
  taints: # Avoid scheduling actual running pods to fake Node
    - effect: NoSchedule
      key: kwok.x-k8s.io/node
      value: fake
status:
  allocatable:
    cpu: "64"
    ephemeral-storage: 1Ti
    hugepages-1Gi: "0"
    hugepages-2Mi: "0"
    memory: 250Gi
    pods: "110"
  capacity:
    cpu: "64"
    ephemeral-storage: 1Ti
    hugepages-1Gi: "0"
    hugepages-2Mi: "0"
    memory: 250Gi
    pods: "128"
  nodeInfo:
    architecture: amd64
    bootID: ""
    containerRuntimeVersion: ""
    kernelVersion: ""
    kubeProxyVersion: fake
    kubeletVersion: fake
    machineID: ""
    operatingSystem: linux
    osImage: ""
    systemUUID: ""
  phase: Running
EOF

# create nodes as you needed
for i in {0..99}; do sed "s/{NODE_NAME}/kwok-node-$i/g" /tmp/node.yaml | kubectl apply -f -; done

go install github.com/k-cloud-labs/scheduler-stress-test@latest

# 创建 1000 个 pod,使用 1000 的并发级别（namespace: scheduler-stress-test）
scheduler-stress-test create --kubeconfig=${KUBECONFIG} --count 1000 --concurrency 1000 --pod-template=$1

# 等待结果
scheduler-stress-test wait --kubeconfig=${KUBECONFIG} --namespace=$2
