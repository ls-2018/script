#! /usr/bin/env zsh
if [ $# -eq 0 ]; then
	exit 1
else
	ns=$1
fi
set -x
kubectl delete deployment --all -n $ns --force
kubectl delete daemonset --all -n $ns --force
kubectl delete statefulset --all -n $ns --force
kubectl delete persistentvolumeclaim --all -n $ns --force
kubectl api-resources --namespaced=true -o name |
	grep -v 'events\|events.k8s.io' |
	xargs -I{} -P 10 kubectl delete {} --all -n $ns --ignore-not-found

kubectl delete ns $ns --force --timeout=2s || echo timeout
kubectl get namespace $ns -o json >/tmp/terminate.json

cat >/tmp/terminate.py <<EOF
import json
try:
    with open("/tmp/terminate.json",'r',encoding='utf8') as f :
        data = json.loads(f.read())
        data['spec']= {}
        data['metadata']['finalizers']= []
        data['status']= {}
except Exception as e :
    print(e)
    data={}
with open("/tmp/terminate.json",'w',encoding='utf8') as f :
    f.write(json.dumps(data))
EOF

python3 /tmp/terminate.py

kubectl proxy --port=8081 &

sleep 3
curl -k -H "Content-Type: application/json" -X PUT --data-binary @/tmp/terminate.json http://127.0.0.1:8081/api/v1/namespaces/$ns/finalize/

pkill -9 kubectl

kubectl get ns
