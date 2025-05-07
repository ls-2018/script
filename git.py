#!/usr/bin/env python3
import os
import subprocess
import sys

cmd = []
base = os.getcwd()
root = subprocess.getoutput('git rev-parse --show-toplevel')

if os.path.exists(os.path.join(base, '.git/config')):
    with open(os.path.join(base, '.git/config'), 'r') as f:
        data = f.read()
        if 'datacanvas' not in data and 'add' in sys.argv:
            os.system(f'cd {base} && git config user.name "acejilam"')
            os.system(f'cd {base} && git config user.email "acejilam@gmail.com"')

cmd.append('\\git')
cmd.extend(sys.argv[1:])
os.system(' '.join(cmd))
