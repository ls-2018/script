#! /usr/bin/env zsh
set -x
podNameSpace=${1-kind}
podName=${2-kind}
nodeName=$(kubectl get pods -n $podNameSpace -owide | grep $podName | awk '{print $9}')

cmd='[ "nsenter", "--target", "1", "--mount", "--uts", "--ipc", "--net", "--pid", "--","bash"]'
overrides="$(
  cat <<EOT
{
  "spec": {
    "nodeName": "$nodeName",
    "hostPID": true,
    "hostNetwork": true,
    "hostIPC": true,
    "containers": [
      {
        "securityContext": {
          "privileged": true
        },
        "image": "registry.cn-hangzhou.aliyuncs.com/acejilam/centos:7",
        "name": "nsenter",
        "stdin": true,
        "stdinOnce": true,
        "tty": true,
        "command": $cmd
      }
    ],
    "tolerations": [
      {
        "operator": "Exists"
      }
    ]
  }
}
EOT
)"

# pod="kube-nodeshell-$(env LC_ALL=C tr -dc a-z0-9 </dev/urandom | head -c 6)"
pod="kube-nodeshell-ls"
kubectl delete pod $pod --force

kubectl run --image=registry.cn-hangzhou.aliyuncs.com/acejilam/centos:7 --restart=Never --overrides="$overrides" $pod

kubectl wait --for=condition=Ready pod/$pod

cat <<EOT >/tmp/down.txt
set -ex
cd /tmp
rm -rf /tmp/crictl*
VERSION="v1.30.0"
curl -L https://files.m.daocloud.io/github.com/kubernetes-sigs/cri-tools/releases/download/\$VERSION/crictl-\$VERSION-linux-amd64.tar.gz --output crictl-\$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-\$VERSION-linux-amd64.tar.gz -C /tmp/
rm -f crictl-\$VERSION-linux-amd64.tar.gz
EOT

cat <<EOT >/tmp/copy.txt
id=\$(/tmp/crictl ps --label io.kubernetes.pod.name=$podName -o json | grep id | grep -v uid | awk -F '"' '{ print \$4 }')
logPath=\$(/tmp/crictl inspect \$id | grep logPath | awk -F '"' '{ print \$4 }')
copyPath=\$(dirname \$logPath)
echo \$copyPath
EOT

kubectl cp /tmp/down.txt default/$pod:/tmp/down.txt
kubectl cp /tmp/copy.txt default/$pod:/tmp/copy.txt
kubectl exec $pod bash /tmp/down.txt
logPath=$(kubectl exec $pod bash /tmp/copy.txt)
mkdir -p ./logs/$podName
kubectl cp default/$pod:$logPath ./logs/$podName

kubectl delete pod $pod --force
