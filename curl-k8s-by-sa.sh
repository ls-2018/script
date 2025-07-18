#!/usr/bin/env bash

echo "=========== SA 类型的 secret ============="
# kubectl get secret -A -o jsonpath="{range .items[?(@.type=='kubernetes.io/service-account-token')]}{.metadata.namespace}{'\t'}{.metadata.name}{'\n'}{end}"
kubectl get secrets --field-selector type=kubernetes.io/service-account-token -A

ns=$1
secret=$2
url=$3

if [[ "$ns" == "" || "$secret" == "" ]]; then
	echo "Usage: $0 <namespace> <secret-name>"
	exit 1
fi

TOKEN=$(kubectl describe secrets $secret -n $ns | grep -E '^token' | cut -f2 -d':' | tr -d '\t' | tr -d ' ')
APISERVER=$(kubectl config view --minify | grep server | cut -f 2- -d ":" | tr -d " ")

curl --header "Authorization: Bearer $TOKEN" --insecure $APISERVER$url
