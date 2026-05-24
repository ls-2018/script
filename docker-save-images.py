#!/usr/bin/env python3
import json
import os
import shutil
import subprocess

save_path = "/Volumes/Tf/docker_images"
os.makedirs(save_path, exist_ok=True)

cmds = ['set -x']
for item in subprocess.getoutput('docker images --format json').split('\n'):
    item = json.loads(item)
    image = item['Repository']
    tag = item['Tag']
    if tag == '<none>':
        continue
    save_name = image.replace('/', '@')
    cmds.append(f'docker save -o {save_path}/{save_name}#{tag}.tar.gz {image}:{tag}')

with open('/tmp/save-c.sh', 'w', encoding='utf8') as f:
    f.write('\n'.join(cmds))
os.system('bash /tmp/save-c.sh')
