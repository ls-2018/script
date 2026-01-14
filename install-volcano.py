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
curl -o /tmp/volcano/volcano.yaml https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-development.yaml
curl -o /tmp/volcano/volcano-agent-development.yaml https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-agent-development.yaml

""")
os.system('bash /tmp/volcano.sh')
os.system('trans_image_name.py /tmp/volcano')
os.system('kubectl apply -f /tmp/volcano')

# docker.io/volcanosh/vc-controller-manager:latest
# docker.io/volcanosh/vc-scheduler:latest
# docker.io/volcanosh/vc-webhook-manager:latest
# docker.io/volcanosh/vc-agent:latest