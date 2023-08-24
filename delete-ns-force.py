#!/usr/bin/env python3
import json
import os
import sys
import time

if len(sys.argv) != 2:
    print(sys.argv)
    print('./delete-ns-force.py "$ns"')
    sys.exit(1)
path = sys.argv[1]
file_path = "/tmp/%s.json" % sys.argv[1]
os.system("kubectl get namespace %s -ojson > %s " % (sys.argv[1], file_path))

data = {}
with open(file_path, 'r', encoding='utf8') as f:
    data = json.loads(f.read())

del data['spec']['finalizers']
del data['status']
with open(file_path, 'w', encoding='utf8') as f:
    f.write(json.dumps(data, indent=4, ensure_ascii=False))
os.system('pkill -9 kubectl')
os.system('kubectl proxy --port=8081 &')
time.sleep(1)
os.system('curl -k -H "Content-Type: application/json" -X PUT ' +
          '--data-binary @%s http://127.0.0.1:8081/api/v1/namespaces/%s/finalize' % (file_path, sys.argv[1]))
