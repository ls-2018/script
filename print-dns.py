#!/usr/bin/env python3
import requests
from prettytable import PrettyTable

data = requests.get('http://127.0.0.1:9353/api/v1').text.strip()
table = PrettyTable(['domain', 'ttl', 'type', 'ip', 'id'])

for line in data.split('\n'):
    line = line.strip()
    desc, ID = line.split(';')
    domain, ttl, _, _type, ip = desc.strip().split(' ')
    if 'PTR' in _type:
        continue
    table.add_row([domain[:-1], ttl, _type, ip, ID.strip('ID:')])

print(table)
