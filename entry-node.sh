#! /usr/bin/env zsh

img=$(trans-image-name quay.io/centos/centos:7)

cmd='[ "nsenter", "--target", "1", "--mount", "--uts", "--ipc", "--net", "--pid", "--","bash"]'
overrides="$(
	cat <<EOT
{
  "spec": {
    "nodeName": "$1",
    "hostPID": true,
    "hostNetwork": true,
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
kubectl run --image=$img --restart=Never --rm --overrides="$overrides" -it $pod
