#!/usr/bin/env python3
import os
import re
import shutil
import subprocess
import sys
import asyncio
import aiohttp
import requests
from bs4 import BeautifulSoup

print(sys.argv)
if len(sys.argv) < 4:
    print('`pwd` net/netfilter/nf_tables_core.c')
    sys.exit(1)
path = sys.argv[1]
file_path = sys.argv[2]
func = sys.argv[3]
# path = '/Users/acejilam/Desktop/book/ebpf/ebpf-nftrace'
# file_path = 'net/netfilter/nf_tables_core.c'

try:
    os.makedirs(f'{path}/kernel_sources', exist_ok=True)
except Exception:
    pass
concurrency = 200


async def get_info():
    vs = set()
    res = requests.get('https://elixir.bootlin.com/linux/v6.10.3/source')
    for line in res.text.split('\n'):
        x = re.findall('<a href=".*source">', line.strip())
        version = line.strip().split('/')
        if len(x) > 0:
            vc = version[2].strip(' v')
            if vc.startswith('4') or vc.startswith('5') or vc.startswith('6'):
                vs.add('v' + vc)
    return vs


async def fetch_code(version, semaphore):
    async with semaphore:  # 使用信号量限制并发
        async with aiohttp.ClientSession() as session:
            global file_path
            try:
#                 print(f'https://elixir.bootlin.com/linux/{version}/source/{file_path}')
                async with session.get(
                        f'https://files.m.daocloud.io/elixir.bootlin.com/linux/{version}/source/{file_path}'
                ) as response:
                    if response.status == 200:
                        v = "{:_<10}".format(version)
                        p = f'{path}/kernel_sources/{v}/{os.path.basename(file_path)}'
                        if os.path.exists(p):
                            return
                        print(version)
                        text = await response.text()
                        os.makedirs(f"{path}/kernel_sources/{v}", exist_ok=True)

                        with open(p, 'w') as f:
                            soup = BeautifulSoup(text, 'html.parser')
                            # 查找所有 class 是 'code' 的 td 标签
                            td_tags = soup.find_all('td', class_='code')
                            # 提取所有 td 标签中的文本
                            texts = [td.get_text() for td in td_tags]
                            f.write('\n'.join(texts))

            except Exception as e:
                pass


async def get_all_codes():
    tags = await get_info()
    print("len tags", len(tags))
    global concurrency
    semaphore = asyncio.Semaphore(concurrency)  # 定义信号量
    tasks = [fetch_code(_version, semaphore) for _version in sorted(tags, reverse=True)]
    # 并发运行所有任务并等待结果
    results = await asyncio.gather(*tasks)
    return results


def split_print(lines):
    maps = {}
    for line in lines.split("\n"):
        ss = line.strip().split(os.path.basename(file_path))
        if len(ss) < 2:
            continue
        if ss[1] not in maps:
            maps[ss[1]] = ss[0]
        else:
            raw = maps[ss[1]]
            maps[ss[1]] = min(ss[0], raw)
    for k, v in maps.items():
        print(v + os.path.basename(file_path), k)


if __name__ == '__main__':
    asyncio.run(get_all_codes())
    os.system(f'cd {path} && clangformat.sh {path}/kernel_sources')
    cmd = f"cd {path} && grep -r '{func}(' {path}/kernel_sources"
    out = subprocess.getoutput(cmd)
    split_print(out)
