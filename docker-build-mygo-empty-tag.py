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
os.system(f'cd {basedir} && git add . && git commit -s -m "tags" ')
for tag in tags.split('\n'):
    os.system(f'cd {basedir} && git tag -d {tag}')
    os.system(f'cd {basedir} && git tag {tag}')
os.system(f'cd {basedir} && git push')
os.system(f'cd {basedir} && git push --tags --force')
