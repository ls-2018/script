#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys
import asyncio
import aiohttp

print(sys.argv)
if len(sys.argv) < 6:
    print('`pwd` {github|gitee} {proxy} net/netfilter/nf_tables_core.c {func} ')
    sys.exit(1)
path = sys.argv[1]
site = sys.argv[2]
proxy = sys.argv[3]
file_path = sys.argv[4]
func = sys.argv[5]

# path = '/Users/acejilam/Desktop/book/ebpf/ebpf-nftrace'
# file_path = 'net/netfilter/nf_tables_core.c'
# res = requests.get('https://elixir.bootlin.com/linux/v6.10.3/source')
try:
    os.makedirs(f'{path}/kernel_sources', exist_ok=True)
except Exception:
    pass

concurrency = 20


# vs = set()
# for line in res.text.split('\n'):
#     x = re.findall('<a href=".*source">', line.strip())
#     version = line.strip().split('/')
#     if len(x) > 0:
#         vc = version[2].strip(' v')
#         if vc.startswith('4') or vc.startswith('5') or vc.startswith('6'):
#             vs.add('v' + vc)
# print(len(vs))


async def fetch_url_info(url, semaphore):
    """发送 GET 请求并返回响应的文本内容"""
    async with semaphore:  # 使用信号量限制并发
        async with aiohttp.ClientSession() as session:
            try:
                async with session.get(url) as response:
                    if response.status == 200:
                        res = await response.json()
                        return res
            except Exception as e:
                pass


async def get_info():
    semaphore = asyncio.Semaphore(20)  # 定义信号量
    tasks = []
    for i in range(100):
        url = f'https://gitee.com/mirrors/linux_old1/tags/names.json?search=&page={i}'
        tasks.append(fetch_url_info(url, semaphore))
    # 并发运行所有任务并等待结果
    results = await asyncio.gather(*tasks)

    tags = set()
    for result in results:
        if result:
            for tag_info in result['tags']:
                vc = tag_info['name'].strip(' v')
                if vc.startswith('4') or vc.startswith('5') or vc.startswith('6'):
                    tags.add('v' + vc)

    return tags


async def fetch_code(version, semaphore):
    async with semaphore:  # 使用信号量限制并发
        async with aiohttp.ClientSession() as session:
            global file_path
            try:
                headers = {
                    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
                }
                global site
                if site == 'gitee':
                    url = f'https://gitee.com/mirrors/linux_old1/raw/{version}/{file_path}'
                else:
                    url = f'{proxy}https://raw.githubusercontent.com/torvalds/linux/refs/tags/{version}/{file_path}'
                async with session.get(url, headers=headers) as response:
                    text = await response.text()
                    if response.status == 200:
                        v = "{:_<10}".format(version)
                        p = f'{path}/kernel_sources/{v}/{os.path.basename(file_path)}'
                        if os.path.exists(p):
                            return
                        print(version)
                        os.makedirs(f"{path}/kernel_sources/{v}", exist_ok=True)
                        with open(f'{path}/kernel_sources/{v}/{os.path.basename(file_path)}', 'w') as f:
                            f.write(text)
                    else:
                        print(url, response.status, text)
            except Exception as e:
                print(e)


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
    cmd = f"cd {path} && grep -r '{func}' {path}/kernel_sources"
    print(cmd)
    out = subprocess.getoutput(cmd)
    split_print(out)
