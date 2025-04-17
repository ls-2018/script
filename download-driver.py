#!/usr/bin/env python3

# http://chromedriver.storage.googleapis.com/index.html
# https://googlechromelabs.github.io/chrome-for-testing/
# https://google-chrome.en.uptodown.com/mac/versions
# https://google-chrome-canary.en.uptodown.com/mac
# http://chromedriver.storage.googleapis.com/?delimiter=/&prefix=

import io
import os, re, requests, platform
import random
import zipfile

res = requests.get('https://googlechromelabs.github.io/chrome-for-testing/#stable')
os.system('pip3 install lxml bs4')
stable_version = re.findall(r'Stable</a><td><code>([\d.]*)?', res.text)[0]
print("stable version: ", stable_version)
links = re.findall(r'(http.*?\.zip)', res.text)

arch = "mac-arm64" if 'arm' in platform.uname().machine else "mac-x64"

target_path = '/Users/acejilam/software/chromedriver'

unzip_path = f'/tmp/{random.randint(1, 100000)}'
for link in links:
    if 'chromedriver' in link and stable_version in link and arch in link:
        print(link)
        content = requests.get(link).content
        f = zipfile.ZipFile(io.BytesIO(content))
        for file in f.namelist():
            f.extract(file, unzip_path)  # 解压位置
        f.close()
        try:
            os.remove(target_path)
        except Exception:
            pass
        os.rename(f"{unzip_path}/chromedriver-{arch}/chromedriver", target_path)

os.system(f"chmod +x {target_path}")