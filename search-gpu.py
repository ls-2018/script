#!/usr/bin/env python3
password=input("Press Enter to start searching for GPU servers...")
def search(ip):
    print(ip)
    try:
        import paramiko
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(hostname=ip, port=22, username='root', password=password, timeout=0.5)
        stdin, stdout, stderr = client.exec_command("nvidia-smi")

        # 输出命令返回值
        for line in stdout:
            print(line.strip())

        # 关闭连接
        client.close()
    except Exception:
        pass


for i in range(0, 255):
    for j in range(0, 255):
        search('172.20.%d.%d' % (i, j))
