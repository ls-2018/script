#!/usr/bin/env python3
import os
import re
import sys
import requests
import asyncio
import aiohttp

print(sys.argv)
if len(sys.argv) < 3:
    print('`pwd` net/netfilter/nf_tables_core.c')
    sys.exit(1)
path = sys.argv[1]
file_path = sys.argv[2]

res = requests.get('https://elixir.bootlin.com/linux/v6.10.3/source')

try:
    os.makedirs(f'{path}/kernel_sources', exist_ok=True)
except Exception:
    pass

vs = set()
for line in res.text.split('\n'):
    x = re.findall('<a href=".*source">', line.strip())
    version = line.strip().split('/')
    if len(x) > 0:
        vs.add('v' + version[2].strip(' v'))
print(len(vs))
async def fetch(version, semaphore):
    """发送 GET 请求并返回响应的文本内容"""
    async with semaphore:  # 使用信号量限制并发
        async with aiohttp.ClientSession() as session:
            global file_path
            try:
                async with session.get(
                        f'https://raw.githubusercontent.com/torvalds/linux/refs/tags/{version}/{file_path}') as response:
                    if response.status == 200:
                        print(version)
                        text = await response.text()
                        v= "{:_>25}".format(version)
                        os.makedirs(f"{path}/kernel_sources/{v}", exist_ok=True)
                        with open(f'{path}/kernel_sources/{v}/{os.path.basename(file_path)}', 'w') as f:
                            f.write(text)
            except Exception as e:
                pass

async def main():
    """并发发送多个请求"""
    semaphore = asyncio.Semaphore(200)  # 定义信号量
    tasks = [fetch(_version, semaphore) for _version in sorted(vs, reverse=True)]
    # 并发运行所有任务并等待结果
    results = await asyncio.gather(*tasks)
    return results


if __name__ == '__main__':
    asyncio.run(main())
    os.system(f'cp -r /Users/acejilam/Desktop/ebpf/network_topo/.clang-format {path}')
    os.system(f'cd {path} && clangformat.sh {path}')
