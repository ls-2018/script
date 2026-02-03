#! /usr/bin/env python3
import sys

from print_proxy import get_ip

ip = get_ip()

header = f'''kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "{ip}"
  #apiServerPort: 6443
nodes:
- role: control-plane
  extraPortMappings:
#    - containerPort: 31256
#      hostPort: 31256
#      protocol: TCP
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
        certSANs:
          - 127.0.0.1
          - localhost
          - {ip}
        extraArgs:
          audit-log-path: /var/log/kubernetes/kube-apiserver-audit.log
          audit-policy-file: /etc/kubernetes/policies/audit-policy.yaml
        extraVolumes:
          - name: audit-policies
            hostPath: /etc/kubernetes/policies
            mountPath: /etc/kubernetes/policies
            readOnly: true
            pathType: "DirectoryOrCreate"
          - name: "audit-logs"
            hostPath: "/var/log/kubernetes"
            mountPath: "/var/log/kubernetes"
            readOnly: false
            pathType: DirectoryOrCreate
  extraMounts:
    - hostPath: /Users/acejilam/script/audit-policy.yaml
      containerPath: /etc/kubernetes/policies/audit-policy.yaml
      readOnly: true
    - hostPath: /Volumes/Tf/data/kind/logs
      containerPath: /var/log/kubernetes
      readOnly: false
'''

worker = '''- role: worker
'''
for i in range(int(sys.argv[1])):
    header += worker

with open('/tmp/gen-kind.yaml', 'w', encoding='utf8') as f:
    f.write(header)
