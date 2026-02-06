#!/usr/bin/env python3
import subprocess
import sys

domain = 'harbor.ls.com'


def get_ip():
    host = subprocess.getoutput("ipconfig getifaddr en0")
    if host == "":
        host = subprocess.getoutput("ipconfig getifaddr en1")
    return host


if __name__ == '__main__':
    host = get_ip()
    if len(sys.argv) > 1 and sys.argv[1] == "check":
        _ip=''
        with open("/etc/hosts", "r") as f:
            for line in f.readlines():
                if line.strip() and not line.strip().startswith('#') and domain in line:
                    _ip = line.strip().split(' ')[0]
        if host != _ip:
            print("⚠️⚠️⚠️ /etc/hosts {} should be {}, current {}".format(domain, host, _ip))
        sys.exit(0)

    print(f"# {host}")
    print('unset https_proxy && unset http_proxy && unset all_proxy')
    print(f'export https_proxy=http://{host}:7890 http_proxy=http://{host}:7890 all_proxy=socks5://{host}:7890 no_proxy=harbor.ls.com')
