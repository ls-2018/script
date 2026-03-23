#!/usr/bin/env python3
import os
import subprocess
import sys

pwd = os.getcwd()
start = sys.argv[1]

for item in os.listdir(pwd):
    if not item.lower().startswith(start.lower()):
        continue

    project = os.path.join(pwd, item)
    file = os.path.join(project, '.git/config')
    if not os.path.exists(file):
        continue

    remote = subprocess.getoutput(f'cd {project} && git remote get-url origin')
    print(remote)
    os.system(f'open -a "/Applications/Google Chrome.app" "{remote}"')
