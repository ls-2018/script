#!/usr/bin/env python3
import platform
import subprocess
import os
import shutil
import sys
import time
import threading

# 并发启动 VM 并生成 success 文件
vm_names = sys.argv[1:]
print(vm_names)

# 配置路径
vm_path = '/Users/acejilam/Desktop/vm'
script_path = '/Users/acejilam/script'
tmp_path = '/tmp'

# 销毁现有 VM 并清理
os.makedirs(vm_path, exist_ok=True)
os.chdir(vm_path)

# 清理全局状态并杀掉可能残留的进程
subprocess.run(['vagrant', 'global-status', '--prune'], check=False)
subprocess.run(['pkill', '-9', 'vmware-vmx'], check=False)
subprocess.run(['pkill', '-9', 'vagrant'], check=False)

for vm in vm_names:
    subprocess.run(['vagrant', 'destroy', '-f', vm], check=False)
os.system(f"rm -rf {vm_path}/*")

# 删除临时标记文件
for filename in os.listdir(tmp_path):
    if filename.startswith('vm'):
        try:
            os.remove(os.path.join(tmp_path, filename))
        except Exception:
            pass

# 创建符号链接
os.symlink(os.path.join(script_path, 'Vagrantfile'), os.path.join(vm_path, 'Vagrantfile'))
os.symlink(os.path.join(script_path, 'Vagrantfile-single'), os.path.join(vm_path, 'Vagrantfile-single'))

# if platform.system() == 'Darwin':
#     provider = "--provider=vmware_desktop"
# else:
provider = "--provider=virtualbox"

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

# # 保存快照并重载
# os.chdir(vm_path)
# print(['vagrant', 'halt'])
# subprocess.run(['vagrant', 'halt'], check=False)
# print(['vagrant', 'snapshot', 'save', 'init', "--force"])
# subprocess.run(['vagrant', 'snapshot', 'save', 'init', "--force"], check=False)
# print(['vagrant', 'reload'])
# subprocess.run(['vagrant', 'reload'], check=False)
# for vm in vm_names:
#     print(['ssh', f"root@{vm}", 'apt-get install -y build-essential dkms linux-headers-$(uname -r)'])
#     subprocess.run(
#         ['ssh', f"root@{vm}", 'apt-get install -y build-essential dkms linux-headers-$(uname -r)'],
#         check=False
#     )
# print(['vagrant', 'reload'])
# subprocess.run(['vagrant', 'reload'], check=False)
