#!/usr/bin/env python3
import os
import sys
import subprocess

git_set = []

pwd = sys.argv[1]
update = False
if len(sys.argv) == 3 and sys.argv[3].lower() == "true":
    update = True


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
            if dir_file_path.endswith('.git'):
                git_set.append(dir_file_path)


get_file_path(pwd)
print('\n'.join(git_set))

if not update:
    for i, git in enumerate(git_set):
        git_path = os.path.dirname(git)
        print(git_path)
        os.system(f'cd {git_path} && git status')
    sys.exit(0)

for i, git in enumerate(git_set):
    git_path = os.path.dirname(git)
    print(git_path)
    # _id = subprocess.getoutput(
    #     f'cd {git_path} && git log --oneline'
    # ).split('\n')[0].split(' ')[0]

    os.system(
        f'cd {git_path} && git add . && git reset --hard `git show-ref --head --hash=8 2`')
    os.system(
        f'cd {git_path} && git pull')
    os.system(
        f'cd {git_path} && git add . && git reset --hard $((git show-ref --head --hash=8 2>/dev/null || echo 00000000) | head -n1) && git pull')
    # os.system(
    # f'cd {git_path} && git config pull.rebase false && git-pullall.sh')
    print(f"剩余:{len(git_set) - i}")

for git in git_set:
    git_path = os.path.dirname(git)
    os.system(f'cd {git_path} && git status')
