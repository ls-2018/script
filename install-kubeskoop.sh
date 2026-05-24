set -ex
kubectl apply -f ~/script/skoopbundle.yaml

echo '
kubectl -n kubeskoop port-forward service/webconsole 8000:80'
