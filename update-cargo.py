#!/usr/bin/env python3
import os
import sys
import subprocess

git_set = []


# root_path
def get_file_path(root_path, dir_list=[], _set="uploaded_set"):
    # 获取该目录下所有的文件名称和目录名称
    dir_or_files = os.listdir(root_path)
    for dir_file in dir_or_files:
        # 获取目录或者文件的路径
        dir_file_path = os.path.join(root_path, dir_file)
        # 判断该路径为文件还是路径
        if os.path.isdir(dir_file_path):
            dir_list.append(dir_file_path)
            # 递归获取所有文件和目录的路径
            get_file_path(dir_file_path, dir_list)
        elif dir_file_path.endswith('Cargo.toml'):
            git_set.append(dir_file_path)


get_file_path(sys.argv[1])
print('\n'.join(git_set))
for i, git in enumerate(git_set):
    git_path = os.path.dirname(git)
    print(git_path)
    os.system(
        f'cd {git_path} && cargo check')
    print(f"剩余:{len(git_set)-i}")
