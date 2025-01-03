#!/usr/bin/env python3
import os
import shutil

rs = [
    ['docker.io/karmada', 'registry.cn-hangzhou.aliyuncs.com/acejilam'],
    ['image: nginx', 'image: registry.cn-hangzhou.aliyuncs.com/acejilam/nginx'],
    ['opensearchproject', 'registry.cn-hangzhou.aliyuncs.com/acejilam'],
    ['kindest/node', 'registry.cn-hangzhou.aliyuncs.com/acejilam/node'],
    ['image: registry.k8s.io', 'image: registry.cn-hangzhou.aliyuncs.com/acejilam'],
    ['FROM alpine:', 'FROM registry.cn-hangzhou.aliyuncs.com/acejilam/alpine:'],
    ['/.kube"', '/.kube/"'],
    ['replicas: 2', 'replicas: 1'],
    ['ARG BINARY', "RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories\nARG BINARY"],
    [
        r'''wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.3/components.yaml -O "${_tmp}/components.yaml"''',
        r'''wget ${GITHUB_PROXY}/github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.3/components.yaml -O "${_tmp}/components.yaml"
    sed -i'' -e 's@registry.k8s.io/metrics-server@registry.cn-hangzhou.aliyuncs.com/acejilam@g' "${_tmp}/components.yaml"
    ''',
    ]
]

KARMADA_PATH = "/Users/acejilam/Desktop/karmada"


shutil.rmtree(KARMADA_PATH, ignore_errors=True)

os.system(rf'''
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
cd {os.path.dirname(KARMADA_PATH)}
git clone https://github.com/karmada-io/karmada.git
''')



for cd, _dirs, files in os.walk(KARMADA_PATH):
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


os.system(rf'''
cd {KARMADA_PATH}
./hack/local-up-karmada.sh
./hack/deploy-karmada-opensearch.sh  ~/.kube/karmada.config karmada-host
IP=$(kubectl --kubeconfig ~/.kube/karmada.config --context karmada-host -n karmada-system get svc karmada-opensearch -oyaml |yq '.spec.clusterIP')
gsed -i "s@10.240.0.100@$IP@g" ./artifacts/example/resourceregistry.yaml
kubectl --kubeconfig ~/.kube/karmada.config --context karmada-apiserver apply -f ./artifacts/example/resourceregistry.yaml

''')

print(r'''kubectl --kubeconfig ~/.kube/karmada.config --context karmada-apiserver get --raw /apis/search.karmada.io/v1alpha1/search/cache/apis/apps/v1/deployments|  jq '.items[] | [.metadata.name, .metadata.annotations["resource.karmada.io/cached-from-cluster"]]' ''')
