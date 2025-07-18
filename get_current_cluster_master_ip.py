#!/usr/bin/env python3
from urllib.parse import urlparse

import yaml

with open('/Users/acejilam/.kube/config', 'r', encoding='utf8') as f:
    data = yaml.load(f.read(), yaml.BaseLoader)
    for ctx in data['contexts']:
        if ctx['name'] == data['current-context']:
            for cluster in data['clusters']:
                if ctx['context']['cluster'] == cluster['name']:
                    print(urlparse(cluster['cluster']['server']).hostname)
                    break
