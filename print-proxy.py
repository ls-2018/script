#!/usr/bin/env python3
import subprocess

host = subprocess.getoutput("ipconfig getifaddr en0")
print(f"# {host}")
if host == "":
    host = subprocess.getoutput("ipconfig getifaddr en1")
    print(f"# {host}")
print('unset https_proxy && unset http_proxy && unset all_proxy')
print(f'export https_proxy=http://{host}:7890 http_proxy=http://{host}:7890 all_proxy=socks5://{host}:7890')
