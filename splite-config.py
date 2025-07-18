#!/usr/bin/env python3
import copy
import os

os.system("pip3 install pyyaml")

import yaml

template = {
    "apiVersion": "v1",
    "kind": "Config",
    "clusters": [],
    "contexts": [],
    "current-context": "",
    "users": []
}


def find_cluster(_data, name):
    for cluster in _data['clusters']:
        if cluster['name'] == name:
            return cluster


def find_context(_data, name):
    for context in _data['contexts']:
        if context['name'] == name:
            return context


def find_user(_data, name):
    for user in _data['users']:
        if user['name'] == name:
            return user


res = []
with open('/Users/acejilam/.kube/kind-koord', 'r', encoding='utf8') as f:
    data = yaml.load(f.read(), yaml.BaseLoader)

    for item in data['clusters']:
        x = copy.deepcopy(template)
        x["current-context"] = item['name']
        x['clusters'].append(find_cluster(data, item['name']))
        x['users'].append(find_user(data, item['name']))
        x['contexts'].append(find_context(data, item['name']))
        res.append(x)

for item in res:
    with open(f'/Users/acejilam/.kube/{item["current-context"]}', 'w', encoding='utf8') as f:
        f.write(yaml.dump(item))

