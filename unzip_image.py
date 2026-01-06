#! /usr/bin/env python3
import json
import os
import shutil
import subprocess

# image = sys.argv[1].strip()
image = 'sha256:3c407a1378d108155a6233dce6ce158c68e35194bf925b2f19841d18b8fc70ec'
info = subprocess.getoutput(f'docker inspect {image}')

_id = json.loads(info)[0]['Id'][7:]
base_dir = f'/Users/acejilam/Desktop/{_id}'

shutil.rmtree(f"{base_dir}.tar.gz", ignore_errors=True)
shutil.rmtree(f"{base_dir}", ignore_errors=True)
os.makedirs(base_dir, exist_ok=True)

os.system(f'docker save {image} -o {base_dir}.tar.gz')
os.system(f'mkdir -p {base_dir}')
os.system(f'tar -zxf {base_dir}.tar.gz -C {base_dir}')

with open(f'{base_dir}/manifest.json', 'r', encoding='utf8') as f:
    manifest = json.loads(f.read())

layers = manifest[0]['Layers']
config = manifest[0]['Config']

with open(os.path.join(base_dir, config), 'r', encoding='utf8') as f:
    _history = json.loads(f.read())['history']

    history = []
    for layer in _history:
        if not layer.get('empty_layer', False):
            history.append(layer['created_by'])

for item in zip(layers, history):
    print(f'unzip {item[0]} ...')
    unzip_file = os.path.join(base_dir, item[0])
    os.system(f'mv {unzip_file} {unzip_file}.tar.gz')
    os.system(f'mkdir -p {unzip_file}')
    os.system(f'tar -zxf {unzip_file}.tar.gz -C {unzip_file}')
    with open(f"{unzip_file}/cmd.txt", 'w', encoding='utf8') as f:
        f.write(item[1])
    os.system(f'rm -f {unzip_file}.tar.gz')

for item in os.listdir(os.path.join(base_dir, 'blobs/sha256')):
    file = os.path.join(base_dir, 'blobs/sha256', item)
    if os.path.isfile(file):
        os.system(f'chmod 666 {file}')
        with open(file, 'r', encoding='utf8') as f:
            data = json.loads(f.read())
        with open(file, 'w', encoding='utf8') as f:
            f.write(json.dumps(data, ensure_ascii=False, indent=4))
        os.system(f'mv {file} {file}.json')

os.system(f'pycharm {base_dir}')
