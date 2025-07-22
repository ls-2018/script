#! /usr/bin/env python3
import os

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
git status
git commit -s -m "doc"
git push ls --force
''')
    if input("Press Enter to continue...\n").lower() != "n":
        os.system(f"chmod +x /tmp/push.sh")
        os.system(f"/tmp/push.sh")
