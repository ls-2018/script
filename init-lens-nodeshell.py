#!/usr/bin/env python3

import json

from trans_image import trans_image

len_c = '/Users/acejilam/Library/Application Support/Lens/lens-cluster-store.json'
with open(len_c, 'r', encoding='utf8') as f:
    data = json.load(f)
    for node in data['clusters']:
        if 'preferences' in node:
            node['preferences']['nodeShellImage'] = trans_image("quay.io/centos/centos:7")
        else:
            node['preferences'] = {'nodeShellImage': trans_image("quay.io/centos/centos:7")}
with open(len_c, 'w', encoding='utf8') as f:
    f.write(json.dumps(data, indent=4, ensure_ascii=False))
