#!/usr/bin/env python3
import os

from print_proxy import get_ip

ip = get_ip()
data = []
with open('/etc/hosts', 'r', encoding='utf8') as f:
    for line in f.read().strip().split('\n'):
        if 'ls.com' in line:
            continue
        else:
            data.append(line.strip())
data.append(f'{ip} harbor.ls.com')

with open('/tmp/hosts', 'w', encoding='utf8') as f:
    f.write('\n'.join(data))
os.system(f'sudo /bin/mv /tmp/hosts /etc/hosts')

print(ip)

# sudo visudo
# acejilam ALL=(ALL) NOPASSWD: /bin/mv /tmp/hosts /etc/hosts
