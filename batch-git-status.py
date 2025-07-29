#! /usr/bin/env python3
import os
import subprocess

gits = set()
current_dir = os.getcwd()
print(current_dir)
for cd, dirs, files in os.walk(current_dir):
    if cd.endswith('.git'):
        gits.add(cd[:-4])

for git in gits:
    print(git)
    print("✈️ ", git)
    with open('/tmp/sts.sh', 'w') as f:
        f.write(f'''
cd {git}
git add .
git status
''')
    os.system(f"chmod +x /tmp/sts.sh")
    code, txt = subprocess.getstatusoutput(["/tmp/sts.sh"])
    if 'Changes to be committed' in txt:
        print("⚠️", git)
    print(txt)
    if code != 0:
        print(code, "⚠️")
