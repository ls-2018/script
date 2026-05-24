#!/usr/bin/env python3
import os
import sys

pwd = sys.argv[1]

for root, dirs, files in os.walk(pwd):
    for file in files:
        p = os.path.join(root, file)
        if p.endswith(".git/config"):
            with open(p, "r",encoding='utf8') as f:
                lines = f.readlines()
                for line in lines:
                    if line.strip().endswith('.git'):
                        print(line.strip()[5:].strip())