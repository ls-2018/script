#!/usr/bin/env python3
import os
import shlex
import subprocess
import sys

cmds = []
base = os.getcwd()
root = subprocess.getoutput('git rev-parse --show-toplevel')
if os.path.exists(os.path.join(base, '.git/config')):
    with open(os.path.join(base, '.git/config'), 'r') as f:
        data = f.read()
        if 'add' in sys.argv:
            if 'datacanvas' not in data:
                os.system(f'cd "{base}" && git config user.name "acejilam"')
                os.system(f'cd "{base}" && git config user.email "acejilam@gmail.com"')
            else:
                os.system(f'cd "{base}" && git config user.name "刘硕"')
                os.system(f'cd "{base}" && git config user.email "liushuo@zetyun.com"')
cmds.extend(sys.argv[1:])
cmd_str = '\\git ' + ' '.join(shlex.quote(arg) for arg in cmds)

os.system(cmd_str)
