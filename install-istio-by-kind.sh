#!/bin/zsh
# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.12.2 sh -
GO111MODULE="on" go install sigs.k8s.io/kind@v0.17.0

kind delete cluster
echo -e 'kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
        certSANs:
          - 127.0.0.1
          - 192.168.1.192
          - 10.10.10.211
  extraPortMappings:
  - containerPort: 6443
    hostPort: 6443
    protocol: TCP
- role: worker
' >/tmp/kind.yaml

kind create cluster --config /tmp/kind.yaml

kubectl cluster-info --context kind-kind
# docker pull docker.io/istio/examples-bookinfo-details-v1:1.16.2
# docker pull docker.io/istio/examples-bookinfo-productpage-v1:1.16.2
# docker pull docker.io/istio/examples-bookinfo-ratings-v1:1.16.2
# docker pull docker.io/istio/examples-bookinfo-reviews-v1:1.16.2
# docker pull docker.io/istio/examples-bookinfo-reviews-v2:1.16.2
# docker pull docker.io/istio/examples-bookinfo-reviews-v3:1.16.2
# docker pull docker.io/istio/proxyv2:1.12.2
# docker pull docker.io/istio/pilot:1.12.2
# docker pull grafana/grafana:8.1.2
# docker pull docker.io/jaegertracing/all-in-one:1.23
# docker pull quay.io/kiali/kiali:v1.42
# docker pull jimmidyson/configmap-reload:v0.5.0

# kind load docker-image docker.io/istio/examples-bookinfo-details-v1:1.16.2
# kind load docker-image docker.io/istio/examples-bookinfo-productpage-v1:1.16.2
# kind load docker-image docker.io/istio/examples-bookinfo-ratings-v1:1.16.2
# kind load docker-image docker.io/istio/examples-bookinfo-reviews-v1:1.16.2
# kind load docker-image docker.io/istio/examples-bookinfo-reviews-v2:1.16.2
# kind load docker-image docker.io/istio/examples-bookinfo-reviews-v3:1.16.2
# kind load docker-image docker.io/istio/proxyv2:1.12.2
# kind load docker-image docker.io/istio/pilot:1.12.2
# kind load docker-image grafana/grafana:8.1.2
# kind load docker-image docker.io/jaegertracing/all-in-one:1.23
# kind load docker-image quay.io/kiali/kiali:v1.42
# kind load docker-image jimmidyson/configmap-reload:v0.5.0

istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl get services
kubectl get pods
kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
istioctl analyze
kubectl get svc istio-ingressgateway -n istio-system
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export INGRESS_HOST=127.0.0.1
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "$GATEWAY_URL"
echo "http://$GATEWAY_URL/productpage"
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system

pkill -9 kiali
istioctl dashboard kiali &

for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done

sleep 36000
kubectl delete -f samples/addons
istioctl manifest generate --set profile=demo | kubectl delete --ignore-not-found=true -f -
istioctl tag remove default
kubectl delete namespace istio-system
kubectl label namespace default istio-injection-
kind delete cluster
