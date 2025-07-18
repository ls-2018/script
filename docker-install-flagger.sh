kubectl apply -f /Volumes/Tf/resources/3rd/flagger/charts/flagger/crds/crd.yaml

# flagger/flagger
# helm upgrade -i flagger /Volumes/Tf/resources/others/flagger-1.40.0.tgz \
# 	--namespace=istio-system \
# 	--set crd.create=false \
# 	--set meshProvider=istio \
# 	--set metricsServer=http://prometheus:9090 \
# 	--set image.repository=registry.cn-hangzhou.aliyuncs.com/acejilam/flagger

# ghcr.io/fluxcd
change-name.py /Volumes/Tf/resources/3rd/flagger "ghcr.io/stefanprodan" "registry.cn-hangzhou.aliyuncs.com/acejilam" text
change-name.py /Volumes/Tf/resources/3rd/flagger "ghcr.io/fluxcd" "registry.cn-hangzhou.aliyuncs.com/acejilam" text
change-name.py /Volumes/Tf/resources/3rd/flagger "IfNotPresent" "Always" text
change-name.py /Volumes/Tf/resources/3rd/flagger/kustomize/podinfo/ "level=info" "level=debug" text

kubectl apply -k /Volumes/Tf/resources/3rd/flagger/kustomize/istio

kubectl create ns test
kubectl label namespace test istio-injection=enabled

kubectl apply -k /Volumes/Tf/resources/3rd/flagger/kustomize/podinfo

kubectl apply -k /Volumes/Tf/resources/3rd/flagger/kustomize/tester

# kubectl -n test set image deployment/podinfo podinfod=ghcr.io/stefanprodan/podinfo:6.0.1

# kubectl -n test exec -it flagger-loadtester-x，x-xx watch curl http://podinfo-canary:9898/status/500
