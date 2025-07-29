#!/usr/bin/env bash
context="$1"
kubectl_args=""
total_count=0
success_count=0

# 设置 context 参数
if [ -n "$context" ]; then
	kubectl_args="--context=$context"
fi

# 检查 kubectl 连接
if ! kubectl $kubectl_args cluster-info >/dev/null 2>&1; then
	echo "Error: Cannot connect to Kubernetes cluster"
	exit 0
fi

# 获取重启次数大于 0 的 Pod（包含 namespace 信息）
 
restarting_pods_info=$(kubectl $kubectl_args get pods -A --no-headers 2>/dev/null  | awk '$5 > 0 {print $2 " " $1}')

if [ -z "$restarting_pods_info" ]; then
	echo "✓ No pods with restart count > 0 found"
	exit 0
fi

# 统计总数
total_count=$(echo "$restarting_pods_info" | wc -l)
echo "Found $total_count pod(s) with restart count > 0:"
echo "----------------------------------------"
echo "$restarting_pods_info" | while read pod namespace; do
	echo "  • $pod (namespace: $namespace)"
done
echo "----------------------------------------"

# 删除 Pod
echo "$restarting_pods_info" | while read pod namespace; do
	echo "🗑️  Deleting: $pod in namespace: $namespace"
	if kubectl $kubectl_args delete pod "$pod" -n "$namespace" --ignore-not-found=true >/dev/null 2>&1; then
		((success_count++))
		echo "  ✓ Successfully deleted: $pod"
	else
		echo "  ✗ Failed to delete: $pod"
	fi
done

echo "----------------------------------------"
echo "Operation completed: $success_count/$total_count pod(s) deleted successfully"
