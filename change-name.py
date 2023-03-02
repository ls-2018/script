#! /usr/bin/env python3
import os
import sys

# sys.argv = 'change-name.py /Users/acejilam/Desktop/raft-demo "github.com/hashicorp/raft" "raft-demo/raft" x'.split(' ')

if len(sys.argv) < 3:
    print(sys.argv)
    # print('./change-name.py "`pwd`" "repalce_context" "new_context" text')
    print('./change-name.py "`pwd`" "repalce_context" "new_context"')
    sys.exit(1)
path = sys.argv[1]
replace = sys.argv[2]
CONTEXT = sys.argv[3]


# path = '/Users/acejilam/Downloads/ASD'
# replace = "更多课程【www.sisuoit.com】"
# CONTEXT = ''


def get_file_path(root_path):
    # 获取该目录下所有的文件名称和目录名称
    dir_or_files = os.listdir(root_path)
    for dir_file in dir_or_files:
        # 获取目录或者文件的路径
        dir_file_path = os.path.join(root_path, dir_file)
        # 判断该路径为文件还是路径
        if os.path.isdir(dir_file_path):
            new_dir_file_path = dir_file_path.replace(replace, CONTEXT)
            os.rename(dir_file_path, new_dir_file_path)
            # 递归获取所有文件和目录的路径
            get_file_path(new_dir_file_path)
        else:
            try:
                if len(sys.argv) == 5:
                    with open(dir_file_path, 'r', encoding='utf8') as f:
                        x = f.read()
                        data = x.replace(replace, CONTEXT)
                    with open(dir_file_path, 'w', encoding='utf8') as f:
                        f.write(data)
            except Exception:
                print(dir_file_path)
            os.rename(dir_file_path, dir_file_path.replace(replace, CONTEXT))


if __name__ == '__main__':
    get_file_path(path)
