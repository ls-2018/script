# #!/usr/bin/env python
# import json
# import os
#
# import requests
#
# domains = {}
# with open('{}/data/mydns/dns.json'.format(os.environ['HOME']), 'r', encoding='utf8') as f:
#     domains = json.loads(f.read())
#
# for domain, ip in domains.items():
#     res = requests.post('http://192.168.1.200:9353/api/v1', data='%s 4294967296 IN A %s' % (domain, ip)).text
#     print(domain, ip, res)
import requests

host = '192.168.10.10'
res = requests.post(f'http://{host}:9353/api/v1',
                    data='%s 4294967296 IN A %s' % ('www.xxx.com', '1.1.1.1')).text
print(res)
res = requests.post(f'http://{host}:9353/api/v1',
                    data='%s 4294967296 IN A %s' % ('www.xxx.com', '1.1.1.2')).text
print(res)
