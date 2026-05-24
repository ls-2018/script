#!/usr/bin/env python3
import shutil
import os
import sys
import copy

# sys.argv = ['/Users/acejilam/script/print-chinese-paths.py', '/Users/acejilam/Downloads/Desktop/redis_cn', 'drop']
print(sys.argv)

if len(sys.argv) < 2:
    print(sys.argv)
    print('./print-chinese-paths.py "`pwd`"')
    sys.exit(1)

file_set = set()


def get_all_repo(root_path):
    # 获取该目录下所有的文件名称和目录名称
    if not os.path.isdir(root_path):
        file_set.add(root_path)
        return
    dir_or_files = os.listdir(root_path)
    if len(sys.argv) == 3 and len(dir_or_files) == 0 and os.path.isdir(root_path):
        shutil.rmtree(root_path)
        return
    for dir_file in dir_or_files:
        # 获取目录或者文件的路径
        dir_file_path = os.path.join(root_path, dir_file)
        # 判断该路径为文件还是路径
        if os.path.isdir(dir_file_path):
            # 递归获取所有文件和目录的路径
            get_all_repo(dir_file_path)
        else:
            file_set.add(dir_file_path)


get_all_repo(sys.argv[1])


def is_chinese(string):
    """
    检查整个字符串是否包含中文
    :param string: 需要检查的字符串
    :return: bool
    """
    for ch in string:
        if u'\u4e00' <= ch <= u'\u9fff':
            print(ch,string)
            return True

    return False


a = list(file_set)
a.reverse()
a = copy.deepcopy(a)
for file in a:
    try:
        with open(file, "r", encoding='utf8') as f:
            data = f.read()
            if is_chinese(data):
                print(file)
            else:
                if len(sys.argv) == 3:
                    os.remove(file)
    except Exception as e:
        pass
# [\u4e00-\u9fa5]
