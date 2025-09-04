#! /usr/bin/env zsh
set -x
. $(cd "$(dirname "$0")"; pwd)/alias.sh
change-name.py /Volumes/Tf/resources/yaml/metrics-server/ "registry.k8s.io/metrics-server" "registry.cn-hangzhou.aliyuncs.com/acejilam" text
# change-name.py /Volumes/Tf/resources/yaml/metrics-server/ "args:" "args:\\n" text

if grep -q "kubelet-insecure-tls" /Volumes/Tf/resources/yaml/metrics-server/components.yaml; then
	echo "kubelet-insecure-tls"
else
	sed -i 's@args:@args:\n        - --kubelet-insecure-tls@g' /Volumes/Tf/resources/yaml/metrics-server/components.yaml
fi

kubectl apply -f /Volumes/Tf/resources/yaml/metrics-server/components.yaml
