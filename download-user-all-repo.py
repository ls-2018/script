#!/usr/bin/env python3
import json
import os
import sys, subprocess

print(sys.argv)
if len(sys.argv) < 3:
    print('who?={users|orgs} type={users|orgs} ')
    sys.exit(1)
who = sys.argv[1]
_type = sys.argv[2]
prefix = ""
try:
    os.mkdir(who)
except Exception:
    pass
prefix = f'cd {who} && '

for page in range(10):
    print(f'-------------> {page}')
    cmd = f'curl -s https://api.github.com/{_type}/{who}/repos?page={page}&per_page=1000 | grep -e \'clone_url*\' | cut -d \\" -f 4  '
    res = subprocess.getoutput(cmd)
    for item in json.loads(res):
        try:
            repo = item['clone_url']
            name = repo.split('/')[-1].split('.')[0]
            if name in sys.argv[3:]:
                continue
            if repo.endswith('/linux.git') or repo.endswith('/bpf.git'):
                continue
            cmd = f'{prefix} git clone {repo} || echo {repo} exists'
            os.system(cmd)
        except Exception:
            print(res)
