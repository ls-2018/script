#!/usr/bin/env python3
import json
import os
import subprocess
import sys

raw_image = sys.argv[1].strip(' /')
os.system(f"docker pull {raw_image}")

split_len = raw_image.count('/')
me_domain = 'harbor.ls.com'
if split_len == 1:
    new_image = me_domain + '/' + raw_image
else:
    ss = raw_image.split('/')
    ss[0] = me_domain
    new_image = '/'.join(ss)

os.system(f"docker tag {raw_image} {new_image}")

user = raw_image.split('/')[-2].strip()
ps_data = subprocess.getoutput(
    f'curl -s -X GET -H "Content-Type: application/json" "https://{me_domain}/api/v2.0/projects?page=1&page_size=100&with_detail=true"'
)
users = set([item['name'] for item in json.loads(ps_data)])
if user not in users:
    os.system(
        f"""curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://{me_domain}/api/v2.0/projects/" -d '{{"project_name": "{user}", "public": true}}'""")

os.system(f"docker push {new_image}")
os.system(f"docker rmi {raw_image}")
os.system("docker image prune -f")
