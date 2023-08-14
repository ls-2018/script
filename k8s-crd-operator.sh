kubectl --kubeconfig=${KUBECONFIG} get mutatingwebhookconfigurations -A
kubectl --kubeconfig=${KUBECONFIG} get validatingwebhookconfigurations -A
kubectl --kubeconfig=${KUBECONFIG} get customresourcedefinitions -A
