#!/usr/bin/env python3
import os
import shutil

save_path = "/Volumes/Tf/docker_images"
os.makedirs(save_path, exist_ok=True)

cmds = ['set -x']
for file in os.listdir(save_path):
    p = os.path.join(save_path, file)
    if file.endswith(".tar.gz"):
        cmds.append(f'docker image load -i {p}')

with open('/tmp/load-c.sh', 'w', encoding='utf8') as f:
    f.write('\n'.join(cmds))
os.system('bash /tmp/load-c.sh')
