#! /usr/bin/env zsh
podNameSpace=${1-kind}
podName=${2-kind}
nodeName=$(kubectl get pods -n $podNameSpace -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName | grep $podName | awk '{print $2}')
echo "copy-pod-logs.sh \$podNameSpace \$podName "
echo "nodeName: " $nodeName

if [[ $nodeName == "<none>" ]]; then
	exit
fi
if [[ $nodeName == "" ]]; then
	exit
fi

img=$(trans_image_name.py quay.io/centos/centos:7)

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
        "image": "$img",
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

kubectl run --image=$img --restart=Never --overrides="$overrides" $pod

kubectl wait --for=condition=Ready pod/$pod

cat <<EOT >/tmp/down.txt
set -ex
cd /tmp
rm -rf /tmp/crictl*
curl -L https://gitee.com/ls-2018/cri-tools/releases/download/v1.31.1/crictl-v1.31.1-linux-amd64.tar.gz --output crictl-v1.31.1-linux-amd64.tar.gz
sudo tar zxvf crictl-v1.31.1-linux-amd64.tar.gz -C /tmp/
rm -rf crictl-v1.31.1-linux-amd64.tar.gz
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
mkdir -p ~/Desktop/logs/$podName
kubectl cp default/$pod:$logPath ~/Desktop/logs/$podName

kubectl delete pod $pod --force
