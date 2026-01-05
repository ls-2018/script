#! /usr/bin/env python3
import os
import sys

d = sys.argv[1]
for item in os.listdir(d):
    if item.endswith(".tar.gz"):
        os.rename(os.path.join(d, item), os.path.join(d, item + '.tar.gz'))

os.system(f'open -R "{d}"')