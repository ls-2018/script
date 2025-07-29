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
    with open('/tmp/push.sh', 'w') as f:
        f.write(f'''
cd {git}
git add .
git commit -s -m "doc" || true 
git push --force
git status
''')
    os.system(f"chmod +x /tmp/push.sh")
    code, txt = subprocess.getstatusoutput(["/tmp/push.sh"])
    print(txt)
    if code != 0:
        print(code, "⚠️")
