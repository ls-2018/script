#! /usr/bin/env zsh
if [ $# -eq 0 ]; then
	exit 1
else
	ns=$1
fi

kubectl api-resources --namespaced=true | awk '{print $1}' | xargs -I F kubectl get F -n $ns -oyaml
