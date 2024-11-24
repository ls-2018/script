#!/usr/bin/env python3
import socket

host = socket.gethostbyname(socket.gethostname())
print(f'export https_proxy=http://{host}:7890 http_proxy=http://{host}:7890 all_proxy=socks5://{host}:7890')
print('unset https_proxy && unset http_proxy && unset all_proxy')
