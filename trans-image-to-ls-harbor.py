#!/usr/bin/env python3
import json
import os
import subprocess
import argparse

parser = argparse.ArgumentParser()

parser.add_argument("--source", default="asd", help="source image")
parser.add_argument("--dest", default="", help="dest image")
parser.add_argument("--arch", default="amd64", help="arch")

args = parser.parse_args()

raw_image = args.source.strip('/')

if len(raw_image.split(':')) == 3:
    raw_image = raw_image.split('@sha')[0]

new_image = args.dest
if new_image == "":
    new_image = raw_image

split_len = len(new_image.split('/')) - 1
me_domain = 'harbor.ls.com'

os.environ['no_proxy'] = me_domain

if split_len == 1:
    new_image = me_domain + '/' + new_image

ss = new_image.split('/')
ss[0] = me_domain
new_image = '/'.join(ss)

user = new_image.split('/')[-2].strip()

ps_data = subprocess.getoutput(
    f'curl -s -X GET -H "Content-Type: application/json" "https://{me_domain}/api/v2.0/projects?page=1&page_size=100&with_detail=true"'
)
if isinstance(json.loads(ps_data), dict):
    print(ps_data)
users = set([item['name'] for item in json.loads(ps_data)])
if user not in users:
    os.system(
        f"""curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://{me_domain}/api/v2.0/projects/" -d '{{"project_name": "{user}", "public": true}}'""")

os.system('skopeo login harbor.ls.com -u admin -p Harbor12345')

if args.arch == 'all':
    cmd = f'skopeo copy --all --dest-tls-verify=false docker://{raw_image} docker://{new_image}'
else:
    cmd = f'skopeo copy --override-arch {args.arch} --override-os linux --format v2s2 --dest-tls-verify=false docker://{raw_image} docker://{new_image}'

print(cmd)
os.system(cmd)
