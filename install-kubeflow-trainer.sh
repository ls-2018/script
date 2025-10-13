install-k8s-by-kind.sh koord v1.30.3
cd ~/Desktop
eval "$(print_proxy.py)"
git clone https://github.com/kubeflow/trainer.git -b v1.9.0
unset https_proxy && unset http_proxy && unset all_proxy
kustomize build trainer/manifests/overlays/standalone | kubectl apply --server-side -f -
