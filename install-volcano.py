#! /usr/bin/env python3
# https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-development.yaml
import os
import subprocess
with open('/tmp/volcano.sh','w',encoding='utf8') as f:
    f.write(f"""
source ~/script/.customer_script.sh
eval "$(print_proxy.py)"
rm -rf /tmp/volcano||true
mkdir /tmp/volcano
set -x 
cd /tmp/volcano
wget -q -nv https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-development.yaml
wget -q -nv https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-agent-development.yaml
wget -q -nv https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-agent-scheduler-development.yaml
wget -q -nv https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-monitoring.yaml
wget -q -nv https://raw.githubusercontent.com/volcano-sh/descheduler/refs/heads/main/installer/volcano-descheduler-development.yaml
""")

os.system('bash /tmp/volcano.sh')
os.system('trans-image-name /tmp/volcano')
os.system('kubectl apply --server-side -f /tmp/volcano/volcano-development.yaml')
os.system('kubectl apply --server-side -f /tmp/volcano/volcano-agent-development.yaml')
os.system('kubectl apply --server-side -f /tmp/volcano/volcano-agent-scheduler-development.yaml')
os.system('kubectl apply --server-side -f /tmp/volcano/volcano-monitoring.yaml')
os.system('kubectl apply --server-side -f /tmp/volcano/volcano-descheduler-development.yaml')

# docker.io/volcanosh/vc-controller-manager:latest
# docker.io/volcanosh/vc-scheduler:latest
# docker.io/volcanosh/vc-webhook-manager:latest
# docker.io/volcanosh/vc-agent:latest
# docker.io/volcanosh/vc-agent-scheduler:latest