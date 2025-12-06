#!/usr/bin/env zsh

rm -rf /tmp/metallb-frr.yaml
cp /Volumes/Tf/resources/yaml/metallb/v0.14.9/metallb-frr.yaml /tmp/metallb-frr.yaml

trans_image_name.py /tmp/metallb-frr.yaml

echo "
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: $(trans_image_name.py docker.io/library/nginx:1.14.2)
        - name: dnsutils
          image: $(trans_image_name.py docker.io/mydlqclub/dnsutils:1.3)
          command: ['/bin/sh', '-c', 'ping 127.0.0.1']
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: 80
  selector:
    app: nginx
  # type: NodePort
  type: LoadBalancer

" | kubectl apply -f -

kubectl apply -f /tmp/metallb-frr.yaml -n metallb-system
kubectl get configmap kube-proxy -n kube-system -o yaml |
	sed-e "s/strictARP: false/strictARP: true/" |
	kubectl apply -f - -n kube-system

kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

kubectl wait -n metallb-system --for=condition=Ready -l app=metallb pod --timeout=3000s

docker network inspect kind | jq '.[0].IPAM.Config'

kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: kind-pool
  namespace: metallb-system
spec:
  addresses:
    - 172.18.0.100-172.18.0.130
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: demo-advertisement
  namespace: metallb-system
EOF
