#!/usr/bin/env python3

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
script_path = os.path.expanduser('~/script')
tmp_path = '/tmp'

# 销毁现有 VM 并清理
os.makedirs(vm_path, exist_ok=True)
os.chdir(vm_path)

subprocess.run(['vagrant', 'destroy', '-f'], check=False)
os.system(f"rm -rf {vm_path}/*")

# 删除临时标记文件
for filename in os.listdir(tmp_path):
    if filename.startswith('vm'):
        try:
            os.remove(os.path.join(tmp_path, filename))
        except Exception:
            pass

# 清理全局状态并杀掉可能残留的进程
subprocess.run(['vagrant', 'global-status', '--prune'], check=False)
subprocess.run(['pkill', '-9', 'vmware-vmx'], check=False)
subprocess.run(['pkill', '-9', 'vagrant'], check=False)

# 创建符号链接
os.symlink(os.path.join(script_path, 'Vagrantfile'), os.path.join(vm_path, 'Vagrantfile'))
os.symlink(os.path.join(script_path, 'Vagrantfile-single'), os.path.join(vm_path, 'Vagrantfile-single'))


def start_vm(vm_name):
    result = subprocess.run(['vagrant', 'up', vm_name])
    if result.returncode == 0:
        with open(f'/tmp/{vm_name}.success', 'w') as f:
            f.write('success')


threads = []
for vm in vm_names:
    t = threading.Thread(target=start_vm, args=(vm,))
    t.start()
    threads.append(t)


# 等待所有 success 文件
def wait_for_file(filepath, timeout=3000):
    for _ in range(timeout):
        if os.path.exists(filepath):
            return True
        time.sleep(1)
    return False


for vm in vm_names:
    file_path = f'/tmp/{vm}.success'
    if not wait_for_file(file_path):
        print(f"超时等待 {file_path}")
        exit(1)

# 保存快照并重载
os.chdir(vm_path)
subprocess.run(['vagrant', 'halt'], check=False)
subprocess.run(['vagrant', 'snapshot', 'save', 'init'], check=False)
subprocess.run(['vagrant', 'reload'], check=False)
