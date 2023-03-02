if [ $# -eq 0 ]; then
    exit 1
else
    ns=$1
fi
kubectl delete deployment --all -n $ns --force
kubectl delete daemonset --all -n $ns --force
kubectl delete statefulset --all -n $ns --force
kubectl delete persistentvolumeclaim --all -n $ns --force
kubectl api-resources --namespaced=true | awk '{print $1}' | xargs -I F kubectl delete F --all -n $ns --force

kubectl delete ns $ns
