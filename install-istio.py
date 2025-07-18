#!/usr/bin/env python3
import os
import shutil
import platform
import sys

print("sys.argv", sys.argv)
print(f"[download=False] [harbor=Flase]" )

deploy_mod = ''
if 'ambient' in sys.argv:
    deploy_mod = 'ambient'
download = False
if 'download' in sys.argv:
    download = True
harbor = 'registry.cn-hangzhou.aliyuncs.com'
 
example = ''
if 'example' in sys.argv:
    example = '''
kubectl apply -f ./samples/bookinfo/platform/kube/bookinfo.yaml -n default
kubectl apply -f ./samples/bookinfo/gateway-api/bookinfo-gateway.yaml -n default

# 这个声明很重要
# kubectl annotate gateway bookinfo-gateway networking.istio.io/service-type=ClusterIP --namespace=default
# kubectl annotate gateway bookinfo-gateway istio.io/service-account=bookinfo-productpage --namespace=default

'''


rs = [
    ['kiwigrid/k8s-sidecar', f'{harbor}/acejilam/k8s-sidecar'],
    ['ghcr.io/prometheus-operator/', f'{harbor}/acejilam/'],
    ['image: pilot', f'image: {harbor}/acejilam/pilot'],
    ['prom/prometheus', f'{harbor}/acejilam/prometheus'],
    ['hub: gcr.io/istio-testing', f'hub: {harbor}/acejilam'],
    ['docker.io/istio/', f'{harbor}/acejilam/'],
    ['quay.io/kiali/kiali', f'{harbor}/acejilam/kiali'],
    ['docker.io/istio', f'{harbor}/acejilam'],
    ['image: apache/', f'image: {harbor}/acejilam/'],
    ['docker.io/jaegertracing', f'{harbor}/acejilam'],
    ['docker.io/grafana', f'{harbor}/acejilam'],
    ['docker.io/mccutchen', f'{harbor}/acejilam'],
    ['image: hiroakis/', f'image: {harbor}/acejilam/'],
    ['image: hiroakis/', f'image: {harbor}/acejilam/'],
    ['image: curlimages/curl', f'image: {harbor}/acejilam/curl'],
    ['image: busybox', f'image: {harbor}/acejilam/busybox'],
    ['image: ghcr.io/spiffe/', f'image: {harbor}/acejilam/'],
    ['image: install-cni',f"image: {harbor}/acejilam/install-cni"],
    ['image: registry.k8s.io/sig-storage/', f'image: {harbor}/acejilam/'],
    ['''  volumeClaimTemplates:
    - apiVersion: v1
      kind: PersistentVolumeClaim
      metadata:
        name: storage
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: "10Gi"''',
     '''        - name: storage
          emptyDir: {}
          '''],
]

proxy = 'export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'

ISTIO_PATH = "/tmp/istio_install"
version = '1.24.3'

platform.system()
arch = ''
if platform.machine() == 'x86_64':
    arch = "amd64"
else:
    arch = "arm64"

shutil.rmtree(ISTIO_PATH, ignore_errors=True)
os.mkdir(ISTIO_PATH)
os.system(rf'''
cd {ISTIO_PATH}
cp /Volumes/Tf/resources/tar/{arch}/istio-{version}-osx-{arch}.tar.gz .
tar zxf istio-{version}-osx-{arch}.tar.gz
# git clone https://github.com/kubernetes-sigs/gateway-api.git -b v1.2.0
''')

os.system(f'cp -rf {ISTIO_PATH}/istio-{version}/bin/istioctl /Users/acejilam/.gopath/bin/istioctl')

image_version = set()
for cd, _dirs, files in os.walk(ISTIO_PATH):
    for file in files:
        path = os.path.join(cd, file)
        if path.endswith('.sh') or path.endswith('.yml') or path.endswith('.yaml') or path.endswith('Dockerfile'):
            with open(path, 'r', encoding='utf8') as f:
                for line in f.readlines():
                    line = line.strip().replace('\'', '').replace('"', '').strip('- ')
                    if 'image: docker.io' in line:
                        image = line.split(' ')[1].strip()
                        image_version.add(image)
if download:
    image_set = set()
    for image in image_version:
        image_set.add(image.split(':')[0])
    for item in image_set:
        print(f"          - '{item}'")

    for i, image in enumerate(sorted(list(image_set))):
        name = image.split('/')[2]
        print(f"{i}/{len(image_set)}", image)
        os.system(
            f'''
            {proxy}
            skopeo copy --all --insecure-policy docker://{image} docker://{harbor}/acejilam/{name}
            '''
        )

for cd, _dirs, files in os.walk(ISTIO_PATH):
    for file in files:
        path = os.path.join(cd, file)
        if path.endswith('.sh') or path.endswith('.yml') or path.endswith('.yaml') or path.endswith('Dockerfile'):
            print(path)
            with open(path, 'r', encoding='utf8') as f:
                data = f.read()
                for item in rs:
                    data = data.replace(item[0], item[1])
            with open(path, 'w', encoding='utf8') as f:
                f.write(data)
for cd, _dirs, files in os.walk(ISTIO_PATH):
    for file in files:
        path = os.path.join(cd, file)
        if path.endswith('.yaml'):
            skip = True
            with open(path, 'r', encoding='utf8') as f:
                data = f.read()
                if 'install.istio.io/v1alpha1' in data and f'hub: {harbor}/acejilam' not in data:
                    skip = False
            if not skip:
                with open(path, 'w', encoding='utf8') as f:
                    install = False
                    spec = False
                    for line in data.split('\n'):
                        f.write(line + '\n')
                        if 'apiVersion: install.istio.io' in line:
                            install = True
                        if 'spec:' in line and install:
                            spec = True
                        if spec and install:
                            f.write(f'  hub: {harbor}/acejilam\n')
                            install = False
                            spec = False

with open(
        os.path.join(f"{ISTIO_PATH}/istio-{version}", "samples/bookinfo/demo-profile-no-gateways.yaml"),
        "a", encoding='utf8') as f:
    f.write('\n')
    f.write('''  meshConfig:
    defaultProviders:
      tracing:
      - "skywalking"
    defaultConfig:
      tracing: {} # 禁用全局的 tracing 配置
    enableTracing: true
    extensionProviders:
    - name: "skywalking"
      skywalking:
        service: tracing.istio-system.svc.cluster.local
        port: 11800''')

mod = ''
mod_after = ''
if deploy_mod == "ambient":
    mod = f'''
istioctl install --set profile=ambient -y --set hub={harbor}/acejilam
# istioctl install -f manifests/profiles/ambient.yaml -y
kubectl label namespace default istio.io/dataplane-mode=ambient
'''
    mod_after = '''
istioctl waypoint apply --enroll-namespace --wait
kubectl get gtw waypoint
'''
else:
    mod = '''
istioctl install -f samples/bookinfo/demo-profile-no-gateways.yaml -y \
  --set meshConfig.outboundTrafficPolicy.mode=REGISTRY_ONLY \
  --set components.ingressGateways[0].name=istio-ingressgateway \
  --set components.ingressGateways[0].enabled=true \
  --set components.ingressGateways[1].name=istio-egressgateway \
  --set components.ingressGateways[1].enabled=true 

kubectl label namespace default istio-injection=enabled
'''

os.system(rf'''
cd {ISTIO_PATH}/istio-{version}

{mod}
# --set meshConfig.outboundTrafficPolicy.mode=ALLOW_ANY|REGISTRY_ONLY
# --set global.proxy.includeIPRanges="10.96.0.0/12"
# --set values.global.logging.level=debug

# kubectl kustomize ../gateway-api/config/crd | kubectl apply -f -

kubectl apply -f {ISTIO_PATH}/samples/addons

kubectl apply -f /Volumes/Tf/resources/yaml/gateway-api/v1.2.0/standard-install.yaml 

{example}

kubectl apply -f samples/addons/extras/skywalking.yaml
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system
kubectl get gateway

{mod_after}


''')

os.system(rf'''kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-viewer
  namespace: default
spec:
  selector:
    matchLabels:
      app: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/bookinfo-gateway-istio
EOF

kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: productpage-viewer
  namespace: default
spec:
  targetRefs:
  - kind: Service
    group: ""
    name: productpage
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/default/sa/curl
    to:
    - operation:
        methods: ["GET"]
EOF

kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: reviews
spec:
  parentRefs:
  - group: ""
    kind: Service
    name: reviews
    port: 9080
  rules:
  - backendRefs:
    - name: reviews-v1
      port: 9080
      weight: 90
    - name: reviews-v2
      port: 9080
      weight: 10
EOF

''')

os.system("""
kubectl delete deployment istio-test --force 
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: istio-test
  labels:
    app: istio-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: istio-test
  template:
    metadata:
      name: istio-test
      labels:
        app: istio-test
    spec:
      containers:
      - name: details
        image: registry.cn-hangzhou.aliyuncs.com/acejilam/buildpack-deps:24.04
        command:
          - "/bin/bash"
          - "-c"
          - "sleep 100d"
        securityContext:
          capabilities:
            add:
              - NET_ADMIN
              - NET_RAW
          runAsUser: 0
          runAsGroup: 0
      restartPolicy: Always
EOF

# kubectl wait --for=jsonpath='{.status.phase}'=Running pod/istio-test

""")

print('''
export PATH=${ISTIO_PATH}/bin:$PATH
kubectl -n default port-forward svc/bookinfo-gateway-istio 8080:80
istioctl dashboard kiali
istioctl dashboard skywalking
istioctl dashboard grafana --address 0.0.0.0
istioctl dashboard prometheus --address 0.0.0.0

kubectl -n default exec deployment/istio-test -- bash -c 'for i in $(seq 1 10000); do curl -s -o /dev/null "http://bookinfo-gateway-istio.default.svc.cluster.local/productpage"; done'

# clean
kubectl label namespace default istio.io/dataplane-mode-
kubectl label namespace default istio.io/use-waypoint-
istioctl waypoint delete --all
istioctl uninstall -y --purge
kubectl delete namespace istio-system
kubectl delete -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl delete -f samples/bookinfo/platform/kube/bookinfo-versions.yaml
kubectl delete -f /Volumes/Tf/resources/yaml/gateway-api/v1.2.0/standard-install.yaml
''')
