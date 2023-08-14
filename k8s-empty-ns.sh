#! /usr/bin/env zsh
if [ $# -eq 0 ]; then
    exit 1
else
    ns=$1
fi
kubectl --kubeconfig=${KUBECONFIG} delete deployment --all -n $ns --force
kubectl --kubeconfig=${KUBECONFIG} delete daemonset --all -n $ns --force
kubectl --kubeconfig=${KUBECONFIG} delete statefulset --all -n $ns --force
kubectl --kubeconfig=${KUBECONFIG} delete persistentvolumeclaim --all -n $ns --force
kubectl --kubeconfig=${KUBECONFIG} api-resources --namespaced=true | awk '{print $1}' | xargs -I F kubectl --kubeconfig=${KUBECONFIG} delete F --all -n $ns --force
kubectl --kubeconfig=${KUBECONFIG} delete ns $ns
kubectl --kubeconfig=${KUBECONFIG} get namespace $ns -o json >/tmp/terminate.json

cat >/tmp/terminate.py <<EOF
import json
with open("/tmp/terminate.json",'r',encoding='utf8') as f :
    data = json.loads(f.read())
    data['spec']= {}
with open("/tmp/terminate.json",'w',encoding='utf8') as f :
    f.write(json.dumps(data))
EOF

python3 /tmp/terminate.py

kubectl --kubeconfig=${KUBECONFIG} proxy --port=8081 &

sleep 3
curl -k -H "Content-Type: application/json" -X PUT --data-binary @/tmp/terminate.json http://127.0.0.1:8081/api/v1/namespaces/$ns/finalize/

pkill -9 kubectl

kubectl --kubeconfig=${KUBECONFIG} get ns
