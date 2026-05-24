NODENAME=$1

if [[ $NODENAME == "" ]]; then
	exit 0
fi
podname=liushuo-node-shell-dev
kubectl -n kube-system delete pod ${podname} --force

node=$(trans-image-name quay.io/centos/centos:7)

echo "apiVersion: v1
kind: Pod
metadata:
  name: ${podname}
  namespace: kube-system
spec:
  containers:
    - name: shell
      image: ${node}
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

kubectl -n kube-system wait --for=condition=Ready pod/${podname} --timeout=3000s
if [ $# -gt 1 ]; then
	kubectl -n kube-system exec -it ${podname} -- bash -c "${@:2}"
else
	kubectl -n kube-system exec -it ${podname} -- bash
fi

kubectl -n kube-system delete pods ${podname}
