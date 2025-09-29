#!/usr/bin/env python3
import os
import subprocess
import sys
import threading

vm_names = sys.argv[1:]
print(vm_names)

# 配置路径
vm_path = '/Users/acejilam/Desktop/vm'
script_path = '/Users/acejilam/script'

dc = ''
for vm in vm_names:
    vc = ' '.join(['vagrant destroy -f', vm])
    dc += vc
    dc += '\n'

rc = ''
for vm in vm_names:
    rc += f'ssh root@{vm} apt-get install -y build-essential dkms linux-headers-$(uname -r)'
    rc = '\n'

pre_cmd = f"""
set -x
mkdir -p {vm_path} 
cd {vm_path}
# 清理全局状态并杀掉可能残留的进程
vagrant global-status --prune
pkill -9 vmware-vmx
pkill -9 vagrant

{dc}
ln -s {script_path}/Vagrantfile ./Vagrantfile
"""
os.system(pre_cmd)

provider = "--provider=virtualbox"

os.chdir(vm_path)
def start_vm(vm_name):
    print(['vagrant', 'up', vm_name, provider])
    result = subprocess.run(['vagrant', 'up', vm_name, provider])
    if result.returncode == 0:
        with open(f'/tmp/{vm_name}.success', 'w') as f:
            f.write('success')
    else:
        sys.exit(1)


threads = []

for vm in vm_names:
    t = threading.Thread(target=start_vm, args=(vm,))
    t.start()
    threads.append(t)
for t in threads:
    t.join()

post_cmd = f"""
cd {vm_path}
set -x
vagrant reload
sleep 5 
{rc}
vagrant halt
vagrant snapshot save init --force
vagrant reload
"""
os.system(post_cmd)
