#! /usr/bin/env zsh
if [ $# -eq 0 ]; then
    exit 1
else
    ns=$1
fi
kubectl proxy --port=8081
kubectl get namespace $ns -o json >/tmp/tmp.json

删除 /tmp/tmp.json spec
# curl -k -H "Content-Type: application/json" -X PUT --data-binary @/tmp/tmp.json http://127.0.0.1:8081/api/v1/namespaces/$ns/finalize
