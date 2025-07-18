NODENAME=$1

if [[ $NODENAME == "" ]]; then
	exit 0
fi

kubectl -n kube-system delete pod node-shell --force

echo "apiVersion: v1
kind: Pod
metadata:
  name: node-shell
  namespace: kube-system
spec:
  containers:
    - name: shell
      image: registry.cn-hangzhou.aliyuncs.com/acejilam/centos:7
      command:
        - nsenter
      args:
        - '-t'
        - '1'
        - '-m'
        - '-u'
        - '-i'
        - '-n'
        - sleep
        - '1d'
      securityContext:
        privileged: true
  restartPolicy: Never
  nodeName: ${NODENAME}
  hostNetwork: true
  hostPID: true
  hostIPC: true
" | kubectl apply -f -

kubectl -n kube-system wait --for=condition=Ready pod/node-shell --timeout=3000s
kubectl -n kube-system exec -it node-shell -- bash
