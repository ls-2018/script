unset https_proxy http_proxy all_proxy
export KUBECONFIG=/Users/acejilam/.kube/172.20.53.21.config
helm install kruise openkruise/kruise --version 1.4.0 --debug
