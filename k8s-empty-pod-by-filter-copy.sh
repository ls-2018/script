#! /usr/bin/env zsh
# i=${1-ImagePullBackOff}
i=${1-Terminating}
alias vk='kubectl --kubeconfig=/Users/acejilam/.kube/vcluster.config'
vk get pods --all-namespaces | grep $i | awk '{print $1,$2}' | while read -r line; do
    namespaces=$(echo $line | awk '{print $1}')
    podname=$(echo $line | awk '{print $2}')
    echo $namespaces -- $podname
    vk delete pod $podname -n $namespaces --force
done
