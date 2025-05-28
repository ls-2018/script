#!/usr/bin/env python3
import os
import sys
import chardet

data = ''
filename = 'zsh_history'
base = '/Users/acejilam/Documents/SyncZone'
# base = '/Users/acejilam/script'

if not os.path.exists(base):
    sys.exit(0)

for cd, dirs, files in os.walk(base):
    if cd != base:
        continue
    for file in files:
        if file.startswith(filename) and file != filename:
            os.system(f'cat {os.path.join(cd, file)} > {os.path.join(cd, filename)}')
            os.remove(os.path.join(cd, file))

file = os.path.join(base, filename)

with open(file, 'rb') as f:
    raw = f.read()

result = chardet.detect(raw)
encoding = result['encoding']
data = raw.decode(encoding, errors='replace')

# with open(file, 'r', encoding='utf-8') as f:
#     try:
#         data = f.read()
#     except UnicodeDecodeError as e:
#         start = 0
#         end = e.start
#         for i in range(0, e.start):
#             if e.object[e.start - i] == 10:
#                 start = e.start - i
#                 break
#         for i in range(e.start + 1, e.end):
#             if e.object[i] == 10:
#                 end = i
#                 break
#         print(e.object[start:end])
#         os.system(f'code {file}')
#     except Exception as e:
#         print(e)
#         os.system(f'code {file}')

t_data = ''
for line in data.split('\n'):
    if line.startswith(': '):
        if line.strip().endswith('\\'):
            continue
        t_data += line + '\n'
if t_data.strip() == "":
    sys.exit(0)

res = {}
vs = set()

for line in t_data.split('\n'):
    if line.strip() == "":
        continue
    ss = line.split(";")
    if len(ss)==2 :
        res[ss[1]] = ss[0]
        vs.add(ss[1])

ks = sorted(list(res.values()))

reversed_dict = {v: k for k, v in res.items()}

with open(file, 'w', encoding='utf-8') as f:
    for t in ks:
        f.write(t + ';' + reversed_dict[t] + '\n')
