#!/usr/bin/env python3

import os
import shutil
import sys

import yaml

print(sys.argv)
print('{write_path} {walk_path}')

if len(sys.argv) != 3:
    sys.exit(1)
write_path = os.path.join(sys.argv[1], "split_yaml")
walk_path = sys.argv[2]

shutil.rmtree(write_path, ignore_errors=True)
os.mkdir(write_path)

file_sets = set()
for cd, dirs, files in os.walk(walk_path):
    for f in files:
        if f.endswith('.yaml'):
            file_sets.add(os.path.join(cd, f))

resources_set = set()

for file in file_sets:
    with open(file, 'r', encoding='utf-8') as f:
        tmp = ""
        for line in f.readlines():
            if line.strip() == '':
                continue
            if line.strip() == '---':
                if tmp.strip() != '':
                    resources_set.add(tmp)
                tmp = ''
            else:
                tmp += line
        if tmp.strip() != '':
            resources_set.add(tmp)

for item in resources_set:
    data = yaml.load(item, yaml.BaseLoader)
    with open(os.path.join(write_path, f"{data['kind']}-{data['metadata']['name']}.yaml"), 'w', encoding='utf-8') as f:
        f.write(yaml.dump(data, allow_unicode=False, default_flow_style=False, indent=2, width=10 ** 10))
