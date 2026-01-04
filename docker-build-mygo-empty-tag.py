#!/usr/bin/env python3
#
import os
import subprocess
import sys

basedir = os.path.dirname(os.path.abspath(__file__))

tags = subprocess.getoutput(f'''
cd {basedir}
git tag -l 
''').strip()
for tag in tags.split('\n'):
    os.system(f'cd {basedir} && git push origin --delete tag {tag}')

for tag in tags.split('\n'):
    os.system(f'cd {basedir} && git tag -d {tag}')

os.system(f'cd {basedir} && git add . && git commit -s -m "tags" ')
os.system(f'cd {basedir} && git push') 

os.system(f'cd {basedir} && git tag -d tags && git push origin --tags --force')