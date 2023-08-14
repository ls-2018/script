#!/bin/zsh
# curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.12.2 sh -

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
kubectl --kubeconfig=${KUBECONFIG} label namespace default istio-injection=enabled
kubectl --kubeconfig=${KUBECONFIG} apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl --kubeconfig=${KUBECONFIG} get services
kubectl --kubeconfig=${KUBECONFIG} get pods
kubectl --kubeconfig=${KUBECONFIG} exec "$(kubectl --kubeconfig=${KUBECONFIG} get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
kubectl --kubeconfig=${KUBECONFIG} apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
istioctl analyze
kubectl --kubeconfig=${KUBECONFIG} get svc istio-ingressgateway -n istio-system
export INGRESS_PORT=$(kubectl --kubeconfig=${KUBECONFIG} -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl --kubeconfig=${KUBECONFIG} -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export INGRESS_HOST=127.0.0.1
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "$GATEWAY_URL"
echo "http://$GATEWAY_URL/productpage"
kubectl --kubeconfig=${KUBECONFIG} apply -f samples/addons
kubectl --kubeconfig=${KUBECONFIG} rollout status deployment/kiali -n istio-system

pkill -9 kiali
istioctl dashboard kiali &

for i in $(seq 1 100); do curl -s -o /dev/null "http://$GATEWAY_URL/productpage"; done

sleep 36000
kubectl --kubeconfig=${KUBECONFIG} delete -f samples/addons
istioctl manifest generate --set profile=demo | kubectl --kubeconfig=${KUBECONFIG} delete --ignore-not-found=true -f -
istioctl tag remove default
kubectl --kubeconfig=${KUBECONFIG} delete namespace istio-system
kubectl --kubeconfig=${KUBECONFIG} label namespace default istio-injection-
kind delete cluster
