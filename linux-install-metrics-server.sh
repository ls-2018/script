#! /usr/bin/env zsh
set -x
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
source "$SCRIPT_DIR/.alias.sh"

trans-image-name /Volumes/Tf/resources/yaml/metrics-server

if grep -q "kubelet-insecure-tls" /Volumes/Tf/resources/yaml/metrics-server/components.yaml; then
	echo "kubelet-insecure-tls"
else
	sed -i 's@args:@args:\n        - --kubelet-insecure-tls@g' /Volumes/Tf/resources/yaml/metrics-server/components.yaml
fi

kubectl apply -f /Volumes/Tf/resources/yaml/metrics-server/components.yaml
