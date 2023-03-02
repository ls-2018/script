#!/usr/bin/env python3
import re

import requests

url = 'http://127.0.0.1:9353/api/v1'
for _id in re.findall(r'ID:(\d+)', requests.get(url).text):
    requests.delete(f'http://localhost:9353/api/v1/id/{_id}')

data = '''
# ----------墨云------------
#10.10.10.12  vcenter.vackbot.com
10.10.10.10 wiki.vackbot.com
10.10.10.20 gitlab.vackbot.com
10.10.10.110 git.vackbot.com
10.10.10.10 jira.vackbot.com
10.10.10.222 harbor.vackbot.com
#10.10.10.223 apiserver.cluster.local
#10.10.10.198 mysql.server
10.10.10.211 nginx.k8s.com
'''
for item in data.strip().split('\n'):
    if item.startswith('1'):
        ip = item.split(' ')[0]
        domain = item.split(' ')[-1]
        print(requests.post(url, data=f'{domain} 600 IN A {ip}').text.strip())
