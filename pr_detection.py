#!/usr/bin/env python3
import os
import sys

if len(sys.argv) != 2:
    print(sys.argv)
    print('./pr_detection.py "`pwd`"')
    sys.exit(1)
path = sys.argv[1]
# path = '/Users/acejilam/Desktop/dapr'
git_set = set()


def get_file_path(root_path, dir_list=[], ):
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
        if dir_file_path.endswith('.go'):
            git_set.add(dir_file_path)


get_file_path(path)

for file in git_set:
    import_str = ''
    start = False
    with open(file, 'r', encoding='utf8') as f:
        for line in f.readlines():
            if not start:
                if line.startswith('import ('):
                    import_str += line
                    start = True
                    continue
            if start and line.strip() == ')' and len(import_str) > 0:
                start = False
                import_str += line
                continue
            if start:
                import_str += line
    if '//' in import_str:
        print(file)
        print(import_str)
