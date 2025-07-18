cd /tmp
rm -rf kube-prometheus
set -e
eval "$(print-proxy.py)"
git clone https://github.com/coreos/kube-prometheus.git -b v0.15.0
unset https_proxy && unset http_proxy && unset all_proxy
cd kube-prometheus/
git checkout v0.15.0
trans_image_name.py dir $(pwd)/manifests/setup
trans_image_name.py dir $(pwd)/manifests

# kubectl delete -f manifests/setup --ignore-not-found=true # 安装 prometheus-operator
# kubectl delete -f manifests/ --ignore-not-found=true || true # 安装 promethes metric adapter

kubectl apply --server-side -f manifests/setup # 安装 prometheus-operator
kubectl apply --server-side -f manifests/      # 安装 promethes metric adapter
# 增大权限
kubectl patch clusterrole prometheus-k8s -p '{"rules":[{"apiGroups":[""],"resources":["nodes/metrics","endpoints","pods","services"],"verbs":["get","list","watch"]},{"nonResourceURLs":["/metrics"],"verbs":["get"]}]}'

kubectl -n monitoring wait --for=condition=Ready pod --all --timeout=3000s
kubectl port-forward --address 0.0.0.0 pod/prometheus-k8s-0 -n monitoring 9090:9090 &
sleep 1
open -a "/Applications/Google Chrome.app" "http://127.0.0.1:9090"
