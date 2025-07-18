#! /usr/bin/env python3
import os
import sys

if len(sys.argv) < 2:
    print(sys.argv)
    print('./change-image-sha256.py "`pwd`" ')
    sys.exit(1)
path = sys.argv[1]
for cd, dirs, files in os.walk(path):
    for f in files:
        path = os.path.join(cd, f)
        print(path)
        try:
            with open(path, 'r', encoding='utf8') as f:
                data = f.read()
                if data[0] == '{':
                    os.rename(path, path + '.json')
                else:
                    os.rename(path, path + '.tar.gz')
        except Exception as e:
            os.rename(path, path + '.tar.gz')
