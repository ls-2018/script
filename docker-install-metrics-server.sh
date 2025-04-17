change-name.py ~/resources/yaml/metrics-server/ "registry.k8s.io/metrics-server" "registry.cn-hangzhou.aliyuncs.com/acejilam" text
# change-name.py ~/resources/yaml/metrics-server/ "args:" "args:\\n" text

if grep -q "kubelet-insecure-tls" ~/resources/yaml/metrics-server/components.yaml; then
	echo "kubelet-insecure-tls"
else
	gsed -i 's@args:@args:\n        - --kubelet-insecure-tls@g' ~/resources/yaml/metrics-server/components.yaml
fi

kubectl apply -f ~/resources/yaml/metrics-server/components.yaml
