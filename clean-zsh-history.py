#!/usr/bin/env python3
data = ''
file = '/Users/acejilam/Documents/同步空间/zsh_history'
with open(file, 'r', encoding='utf-8') as f:
    data = f.read()

t_data = ''
for line in data.split('\n'):
    if line.startswith(': '):
        if line.strip().endswith('\\'):
            continue
        t_data += line + '\n'

res = {}
for line in t_data.split('\n'):
    if line.strip() == "":
        continue
    ss = line.split(";")
    res[ss[1]] = ss[0]

with open(file, 'w', encoding='utf-8') as f:
    for k, v in res.items():
        f.write(v + ';' + k + '\n')
