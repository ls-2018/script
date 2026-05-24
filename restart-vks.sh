#!/bin/bash

# 获取所有 vcluster 命名空间
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep '^vcluster-'); do
	# Deployment 名称与命名空间尾缀相同
	deploy=${ns#vcluster-}
	echo "Restarting deployment $deploy in namespace $ns"
	kubectl rollout restart deployment "$deploy" -n "$ns"
done
