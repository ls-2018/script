#! /usr/bin/env python3
import os
os.system('docker-install-registry.sh')
sources = [
    ("registry.cn-hangzhou.aliyuncs.com/ls-2018/burlyluo_node:v1.27.3", "burlyluo/node:v1.27.3"),
    ("calico/node", "burlyluo/node:v1.27.3"),
    ("registry.cn-hangzhou.aliyuncs.com/ls-2018/burlyluo_ucni", "burlyluo/ucni"),
    ("registry.cn-hangzhou.aliyuncs.com/ls-2018/burlyluo_xcni", "burlyluo/xcni"),
    ("registry.cn-hangzhou.aliyuncs.com/ls-2018/burlyluo_nettool", "burlyluo/nettool"),
]

for repos in sources:
    s = repos[0]
    d = repos[1]
    print(f'------------> {repos}')

    cmd = f'''source /Users/acejilam/script/customer_script.sh
eval "$(print-proxy.py)"
/opt/homebrew/bin/skopeo copy --all --insecure-policy docker://{s} docker://127.0.0.1:5000/{d} --dest-tls-verify=false
'''
    os.system(cmd)
