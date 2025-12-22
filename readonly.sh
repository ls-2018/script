#!/usr/bin/env bash
set -euo pipefail

# ===== 可修改参数 =====
NAMESPACE="default"
SA_NAME="readonly-sa"
ROLE_NAME="readonly-role"
BINDING_NAME="readonly-binding"
KUBECONFIG_OUT="readonly.kubeconfig"
CONTEXT_NAME="readonly-context"
CLUSTER_NAME="readonly-cluster"
USER_NAME="readonly-user"
# =====================

kubectl delete sa ${SA_NAME} -n ${NAMESPACE} --ignore-not-found
kubectl delete clusterrolebindings.rbac.authorization.k8s.io ${BINDING_NAME} -n ${NAMESPACE} --ignore-not-found
kubectl delete clusterroles.rbac.authorization.k8s.io ${ROLE_NAME} -n ${NAMESPACE} --ignore-not-found

echo "▶ 创建 ServiceAccount"
kubectl get sa ${SA_NAME} -n ${NAMESPACE} >/dev/null 2>&1 ||
	kubectl create sa ${SA_NAME} -n ${NAMESPACE}

echo "▶ 创建 ClusterRole（只读）"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${ROLE_NAME}
  namespace: ${NAMESPACE}
rules:
- apiGroups: ["","kubeflow.org","scheduling.volcano.sh","batch.volcano.sh","rbac.authorization.k8s.io"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
EOF

echo "▶ 创建 ClusterRoleBinding"
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${BINDING_NAME}
  namespace: ${NAMESPACE}
subjects:
- kind: ServiceAccount
  name: ${SA_NAME}
  namespace: ${NAMESPACE}
roleRef:
  kind: ClusterRole
  name: ${ROLE_NAME}
  apiGroup: rbac.authorization.k8s.io
EOF

echo "▶ 获取 ServiceAccount Token"
TOKEN=$(kubectl create token ${SA_NAME} -n ${NAMESPACE})

echo "▶ 获取集群信息"
CURRENT_CONTEXT=$(kubectl config current-context)
CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name==\"${CURRENT_CONTEXT}\")].context.cluster}")
SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"${CLUSTER}\")].cluster.server}")
CA_DATA=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name==\"${CLUSTER}\")].cluster.certificate-authority-data}")

echo "▶ 生成 kubeconfig: ${KUBECONFIG_OUT}"
cat <<EOF >${KUBECONFIG_OUT}
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    server: ${SERVER}
    certificate-authority-data: ${CA_DATA}

users:
- name: ${USER_NAME}
  user:
    token: ${TOKEN}

contexts:
- name: ${CONTEXT_NAME}
  context:
    cluster: ${CLUSTER_NAME}
    user: ${USER_NAME}
    namespace: ${NAMESPACE}

current-context: ${CONTEXT_NAME}
EOF

chmod 600 ${KUBECONFIG_OUT}

echo "✅ 完成"
echo "测试："
echo "  KUBECONFIG=${KUBECONFIG_OUT} kubectl get pods"
echo "  KUBECONFIG=${KUBECONFIG_OUT} kubectl delete sa ${SA_NAME}  # 应该失败"
