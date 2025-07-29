#! /usr/bin/env python3
import json
import os
import shutil
import subprocess
import time

head_project = 'https://github.com/kubernetes-sigs/kueue'
project = head_project.split("/")[-1]
os.environ['https_proxy'] = 'http://127.0.0.1:7890'
os.environ['http_proxy'] = 'http://127.0.0.1:7890'
os.environ['all_proxy'] = 'http://127.0.0.1:7890'

need_handle = [
    6089, 6088,
    6086, 6085, 6083, 6082, 6081,
    6080, 6078, 6077,
    6072, 6065, 6064, 6063,
    6062, 6061, 6060, 6058, 6057,
    6052, 6051, 6050, 6049,
    6048, 6047, 6046, 6045, 6042,
]

base_dir = '/Users/acejilam/Desktop'

os.makedirs(f"{base_dir}/{project}_test", exist_ok=True)
os.makedirs(f"{base_dir}/{project}_test/change", exist_ok=True)

os.system(f'''
cd {base_dir}/{project}_test
rm -rf {base_dir}/{project}_test/*
mkdir -p {base_dir}/{project}_test/change
git clone {head_project}.git
''')

# gh pr list --label approved --state=closed --author "@me" -L 1000
for item in json.loads(subprocess.getoutput(
        f'cd {base_dir}/{project}_test/{project} && gh pr list --author "@me" --json number,headRefName --state=closed -L 1000')
):
    print(item)
    number = int(item['number'])
    if number not in need_handle:
        continue
    headRefName = item['headRefName']

    cmd = f'''
source /Users/acejilam/script/customer_script.sh
cd {base_dir}/{project}_test
rm -rf {number}
cp -rf {project} {number}
cd {number}
grs
gh pr checkout {number}
# open -a "/Applications/Google Chrome.app" "{head_project}/pull/{number}"

git log --format="%H" |head -n 2 |awk -F ' ' '{{print $1}}'|tail -n 1  |xargs git reset --soft
'''
    with open("/tmp/pr.sh", 'w') as f:
        f.write(cmd)
    os.system(f"chmod +x /tmp/pr.sh")
    os.system(f"/tmp/pr.sh")

    pr_project = os.path.join(f"{base_dir}/{project}_test", str(number))
    out = subprocess.getoutput(f"cd {pr_project} && git status --porcelain")
    file_map = {}
    for line in out.splitlines():
        f = os.path.join(f"{base_dir}/{project}_test", str(number), line.split(' ')[-1])
        file_map[f] = os.path.join(f"{base_dir}/{project}_test/change", str(number), f'{time.time_ns()}.md')

    os.makedirs(f"{base_dir}/{project}_test/change/{number}", exist_ok=True)
    for k, v in file_map.items():
        shutil.copyfile(k, v)

    copy_file = ''
    for k, v in file_map.items():
        copy_file += f'cp {v} {k}\n'

    cmd = f'''
source /Users/acejilam/script/customer_script.sh
cd {base_dir}/{project}_test
rm -rf {number}
cp -rf {project} {number}
cd {number}
grs
git checkout -b {headRefName}
git remote add ls https://github.com/ls-2018/kueue.git

{copy_file}
# git push --set-upstream ls {headRefName} --force
'''

    with open("/tmp/pr.sh", 'w') as f:
        f.write(cmd)
    os.system(f"chmod +x /tmp/pr.sh")
    os.system(f"/tmp/pr.sh")
