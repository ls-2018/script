#!/usr/bin/env python
import json
import sys

print(sys.argv)
if len(sys.argv) < 2:
    print(sys.argv)
    print('./format-json.py "file"')
    sys.exit(1)
data = {}
with open(sys.argv[1], 'r', encoding='utf8') as f:
    data = json.loads(f.read())
with open(sys.argv[1], 'w', encoding='utf8') as f:
    f.write(json.dumps(data, indent=4, ensure_ascii=False))
