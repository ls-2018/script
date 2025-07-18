#!/usr/bin/env python3
import re

import requests

url = 'http://127.0.0.1:9353/api/v1'
for _id in re.findall(r'ID:(\d+)', requests.get(url).text):
    requests.delete(f'http://localhost:9353/api/v1/id/{_id}')

data = '''
----------home------------
192.168.10.1 nfs
192.168.10.101 k8s-master-1
192.168.10.102 k8s-master-2
192.168.10.103 k8s-master-3
192.168.10.201 k8s-worker-1
192.168.10.202 k8s-worker-2
192.168.10.203 k8s-worker-3
192.168.10.204 k8s-worker-4
192.168.10.205 k8s-worker-5
192.168.10.206 k8s-worker-6
192.168.10.207 k8s-worker-7
192.168.10.208 k8s-worker-8
192.168.10.101 harbor.k8s.com
192.168.10.101 www.foo.com
'''
for item in data.strip().split('\n'):
    if item.startswith('1'):
        ip = item.split(' ')[0]
        domain = item.split(' ')[-1]
        print(requests.post(url, data=f'{domain} 600 IN A {ip}').text.strip())
