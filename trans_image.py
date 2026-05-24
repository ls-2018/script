#!/usr/bin/env python3
import json
import subprocess


def trans_image(x, random_path=None, fixed_path=None):
    with open("/tmp/trans.sh", 'w', encoding='utf8') as f:
        if random_path is not None:
            f.write(f"export RandomImagePath={random_path}\n")
        if fixed_path is not None:
            f.write(f"export FixImagePath={fixed_path}\n")
        f.write(f"trans-image-name {x}")
    return subprocess.getoutput('bash /tmp/trans.sh')


def inner_repo():
    with open("/tmp/repo.sh", 'w', encoding='utf8') as f:
        f.write(f"print-inner-repo")
    return json.loads(subprocess.getoutput('bash /tmp/repo.sh'))
