#!/usr/bin/env python3
import os
os.system('pip3 install toml tomli_w')
import subprocess
import toml
import tomli_w

proxy = '*.tencent.com,*.*.tencentyun.com,harbor.ls.com,*.aliyun.com,*.*.aliyuncs.com,*.aliyuncs.com,*.zetyun.com,quay.io'
with open('/Users/acejilam/Library/Group Containers/group.com.docker/settings-store.json', 'r', encoding='utf-8') as f:
    data = f.read()
    if proxy in data:
        pass
    else:
        input(f"需要再docker的noproxy 中配置: {proxy}")

os.system("kubectl -n kube-system get configmap coredns -oyaml |yq '.data.Corefile' > /tmp/Corefile.yaml")

ip = ''
for i in range(5):
    if ip == '':
        ip = subprocess.getoutput(f'ipconfig getifaddr en{i}')
print(ip)

aliyun = 'ccr.ccs.tencentyun.com'
ls = 'harbor.ls.com'

res = ''
with open('/tmp/Corefile.yaml', 'r', encoding='utf8') as f:
    for line in f.readlines():
        if aliyun in line:
            res += f'''            {ip} {aliyun}\n'''
        elif line.strip().startswith('forward') and aliyun not in res:
            res += '''    hosts {{
            {ip}  {host}
            {ip}  harbor.ls.com
            fallthrough
    }}\n'''.format(ip=ip, host=aliyun)
            res += line
        else:
            res += line

print(res)
with open('/tmp/Corefile.yaml', 'w', encoding='utf8') as f:
    f.write(res)

os.system('kubectl -n kube-system delete configmap coredns')
os.system('kubectl -n kube-system create configmap coredns --from-file=Corefile=/tmp/Corefile.yaml')
os.system('kubectl -n kube-system scale deployment coredns --replicas=0')
os.system('kubectl -n kube-system scale deployment coredns --replicas=1')

with open(f"/tmp/{aliyun}.toml", 'w', encoding='utf8') as f:
    f.write(f'''server = "https://{aliyun}"
capabilities = ["pull", "resolve"]
skip_verify = true

[host."https://{aliyun}"]
  capabilities = ["pull", "resolve"]
  skip_verify = true
  ca = "harbor.crt"
''')

with open(f"/tmp/{ls}.toml", 'w', encoding='utf8') as f:
    f.write(f'''server = "https://{ls}"
capabilities = ["pull", "resolve"]
skip_verify = true

[host."https://{ls}"]
  capabilities = ["pull", "resolve"]
  skip_verify = true
  ca = "harbor.crt"

''')

with open("/tmp/change-host.sh", 'w', encoding='utf8') as f:
    f.write(f'''echo -e "{ip} {aliyun}" >> /etc/hosts''')
    f.write("\n")
    f.write(f'''echo -e "{ip} {ls}" >> /etc/hosts''')


def system(_cmd):
    print(_cmd)
    os.system(_cmd)


ns = subprocess.getoutput("kubectl get nodes |awk -F ' ' '{print $1}'|grep -v NAME").strip().split('\n')
for n in ns:
    system(f'docker cp {n}:/etc/containerd/config.toml /tmp/config.toml')

    data = toml.load("/tmp/config.toml")
    if 'registry' not in data['plugins']['io.containerd.grpc.v1.cri']:
        data['plugins']['io.containerd.grpc.v1.cri']['registry'] = {}
    data['plugins']['io.containerd.grpc.v1.cri']['registry']['config_path'] = '/etc/containerd/certs.d'

    with open(f"/tmp/config.toml", "w", encoding='utf8') as f:
        f.write(tomli_w.dumps(data, multiline_strings=True, indent=4))
        # f.write(toml.dumps(data))
    system(f'docker cp /tmp/config.toml {n}:/etc/containerd/config.toml')

    system(f'docker exec {n} mkdir -p /etc/containerd/certs.d/{aliyun}')
    system(f'docker cp /tmp/{aliyun}.toml {n}:/etc/containerd/certs.d/{aliyun}/hosts.toml')

    system(f'docker exec {n} mkdir -p /etc/containerd/certs.d/{ls}')
    system(f'docker cp /tmp/{ls}.toml {n}:/etc/containerd/certs.d/{ls}/hosts.toml')

    system(f'docker exec {n} systemctl restart containerd')
    system(f'docker cp /Users/acejilam/script/linux-replace-sources.sh {n}:/root/linux-replace-sources.sh')
    system(f'docker exec {n} bash /root/linux-replace-sources.sh')

    system(f'docker cp /tmp/change-host.sh {n}:/root/change-host.sh')

    system(f'docker cp /Volumes/Tf/data/harbor/cert/harbor.crt {n}:/etc/containerd/certs.d/{aliyun}/harbor.crt') # 不生效
    system(f'docker cp /Volumes/Tf/data/harbor/cert/harbor.crt {n}:/etc/containerd/certs.d/{ls}/harbor.crt')# 不生效
    system(f'docker cp /Volumes/Tf/data/harbor/cert/harbor.crt {n}:/usr/local/share/ca-certificates/')# 生效

    system(f'docker exec {n} bash update-ca-certificates')
    system(f'docker exec {n} bash /root/change-host.sh')
    system(f'docker exec {n} apt install iputils-ping -y')
