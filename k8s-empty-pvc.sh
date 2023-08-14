#! /usr/bin/env zsh
kubectl --kubeconfig=${KUBECONFIG} get pv | grep -v STORAGECLASS | grep Released | awk '{print $1}' | xargs -I "F" kubectl --kubeconfig=${KUBECONFIG} patch pv F -p '{"spec":{"claimRef":null}}'

echo "empty path"
kubectl --kubeconfig=${KUBECONFIG} get pv | grep Available | awk '{print $1}' | xargs -I F echo F | xargs kubectl --kubeconfig=${KUBECONFIG} get pv -o yaml | grep path | grep -v spec | awk -F ' ' '{print "rm -rf "$2"/*"}'

echo "harbor permission"
# -
# -harbor-datebase  999
chown -R 1001:1001 /data/volumes/
echo 'chown -R 1001:1001 /data/volumes/'
kubectl --kubeconfig=${KUBECONFIG} get pv | grep 'harbor' | grep -v -E 'harbor-redis|harbor-database' | awk '{print $1}' | xargs -I F echo F | xargs kubectl --kubeconfig=${KUBECONFIG} get pv -o yaml | grep path | grep -v spec | awk -F ' ' '{print "chown -R 10000:10000 "$2""}'
echo 'chown -R 1001:1001 /data/volumes/'
kubectl --kubeconfig=${KUBECONFIG} get pv | grep -E 'harbor-redis|harbor-database' | awk '{print $1}' | xargs -I F echo F | xargs kubectl --kubeconfig=${KUBECONFIG} get pv -o yaml | grep path | grep -v spec | awk -F ' ' '{print "chown -R 999:999 "$2""}'
