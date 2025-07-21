import json
import os
import subprocess

head_project = 'https://github.com/kubernetes-sigs/kueue'
project = head_project.split("/")[-1]
os.environ['https_proxy'] = 'http://127.0.0.1:7890'
os.environ['http_proxy'] = 'http://127.0.0.1:7890'
os.environ['all_proxy'] = 'http://127.0.0.1:7890'

home_dir = os.path.expanduser(os.path.expandvars(os.path.expanduser('~')))
print(home_dir)

os.makedirs(f"{home_dir}/Desktop/{project}_test", exist_ok=True)

os.system(f'''
cd {home_dir}/Desktop/{project}_test
rm -rf {home_dir}/Desktop/{project}_test/*
git clone {head_project}.git
''')

for item in json.loads(subprocess.getoutput(
        f'cd {home_dir}/Desktop/{project}_test/{project} && gh pr list --author "@me" --json number')):
    print(item)
    number = int(item['number'])
    cmd = f'''
source {home_dir}/script/customer_script.sh
cd {home_dir}/Desktop/{project}_test
rm -rf {number}
cp -rf {project} {number}
cd {number}
grs
gh pr checkout {number}
open -a "/Applications/Google Chrome.app" "{head_project}/pull/{number}"

git log --format="%H" |head -n 2 |awk -F ' ' '{{print $1}}'|tail -n 1  |xargs git reset --soft
'''
    with open("/tmp/pr.sh", 'w') as f:
        f.write(cmd)
    print(cmd)
    os.system(f"chmod +x /tmp/pr.sh")
    os.system(f"/tmp/pr.sh")
