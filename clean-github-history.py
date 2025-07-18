#!/usr/bin/env python3
import os
import shutil
import sys

if len(sys.argv) != 2:
    print(sys.argv)
    print('./pr_detection.py "`pwd`"')
    sys.exit(1)
git_path = sys.argv[1]
# git_path = '/Users/acejilam/Desktop/k8sxx'
os.system('git config --global user.email "acejilam@gmail.com"')
os.system('git config --global user.name  "acejilam"')

# path = '/Users/acejilam/Desktop/k8s'


# def get_all_repo(root_path, git_set=[], _set="uploaded_set"):
#     # 获取该目录下所有的文件名称和目录名称
#     dir_or_files = os.listdir(root_path)
#     for dir_file in dir_or_files:
#         # 获取目录或者文件的路径
#         dir_file_path = os.path.join(root_path, dir_file)
#         # 判断该路径为文件还是路径
#         if os.path.isdir(dir_file_path):
#             # 递归获取所有文件和目录的路径
#             get_all_repo(dir_file_path, git_set)
#             if dir_file_path.endswith('.git'):
#                 git_set.append(os.path.dirname(dir_file_path))


log_format = "git log --graph --pretty=format:'%Cred%h%Creset <--> %aI <--> %Cgreen(%ci)%Creset <--> %C(bold blue)<%an>%Creset <--> %s ' --abbrev-commit --date=relative"
log = "cd {git_path} && %s >/tmp/git.log" % log_format


class Item:
    Date = ''
    Ago = ''
    Author = ''
    Message = ''
    Sign = ''


def get_git_log():
    # git_set = []
    # get_all_repo(path, git_set)
    res = []
    # for git_path in set(git_set):

    os.system(log.format(git_path=git_path))
    with open('/tmp/git.log', 'r', encoding='utf8') as f:
        for line in f.readlines():
            if ' <--> ' not in line.strip():
                continue
            my = False
            for p in ['ls-2018', 'acejilam', 'acejilam', 'ls2018']:
                if p in line:
                    my = True
            if not my:
                continue

            sps = [item.strip() for item in line.strip(r" |\*").split('<-->')]
            if len(sps) != 5:
                raise Exception(line)
            temp = Item()
            temp.Sign = sps[0]
            temp.Date = sps[1]
            temp.Ago = sps[2].strip('()')
            temp.Author = sps[3].strip('<>')
            temp.Message = sps[4]
            res.append(temp)
    res.reverse()
    return res


def remove_path(root_path):
    def inner(root_path, _file_list: list, ):
        # 获取该目录下所有的文件名称和目录名称
        dir_or_files = os.listdir(root_path)
        for dir_file in dir_or_files:
            # 获取目录或者文件的路径
            dir_file_path = os.path.join(root_path, dir_file)
            # 判断该路径为文件还是路径
            if os.path.isdir(dir_file_path):
                if dir_file_path != os.path.join(root_path, '.git'):
                    # 递归获取所有文件和目录的路径
                    _file_list.append(dir_file_path)
                    inner(dir_file_path, _file_list)
            else:
                _file_list.append(dir_file_path)

    file_list = []
    inner(root_path, file_list)
    for item in file_list:
        try:
            shutil.rmtree(item)
        except NotADirectoryError:
            os.remove(item)
        except Exception:
            pass


def drop_big_file(root_path):
    def inner(root_path, _file_list: list, ):
        # 获取该目录下所有的文件名称和目录名称
        dir_or_files = os.listdir(root_path)
        for dir_file in dir_or_files:
            # 获取目录或者文件的路径
            dir_file_path = os.path.join(root_path, dir_file)
            # 判断该路径为文件还是路径
            if os.path.isdir(dir_file_path):
                # 递归获取所有文件和目录的路径
                inner(dir_file_path, _file_list)
            else:
                # if os.path.
                if dir_file_path.endswith('.tar.gz'):
                    _file_list.append(dir_file_path)
                if os.stat(dir_file_path).st_size > 10 * 1024 * 1024:
                    _file_list.append(dir_file_path)

    file_list = []
    inner(root_path, file_list)
    for file in file_list:
        os.remove(file)


src = '/tmp/src'
dest = '/tmp/dest'
shutil.rmtree(src, ignore_errors=True)
shutil.rmtree(dest, ignore_errors=True)
os.mkdir(src)
os.mkdir(dest)
first = True
i = 1
all_log = get_git_log()
for item in all_log:  # type:Item
    print(i, len(all_log) - i, item.__dict__)
    remove_path(dest)
    shutil.rmtree(src)
    shutil.copytree(git_path, src, dirs_exist_ok=True)
    os.system(f"cd {src} && git reset --hard {item.Sign}")
    if first:
        os.system(f'cd {dest} && git init ')
        # shutil.copytree(os.path.join(src, '.git'), os.path.join(dest, '.git'))
    shutil.rmtree(os.path.join(src, '.git'), ignore_errors=True)
    os.system(f'cp -R {src}/* {dest}')
    drop_big_file(dest)
    first = False
    os.system(
        f"cd {dest} && git add . && git commit -m \"{item.Message}\" --date=\"{item.Date}\" ")
    i += 1

os.system("%s && cat /tmp/git.log " % (log.format(git_path=dest)))
# 保证源最新
# mkdir -p /tmp/{src,dest}
# rm -rf /tmp/src/* -y
# cp -r src dest
# cd $dest && git reset --hard {}
# 移除dest下除了.git的文件     拷贝src下除了.git的文件到dest目录
# git commit -m ""
shutil.rmtree(git_path, ignore_errors=True)
shutil.copytree(dest, git_path, dirs_exist_ok=True)

os.system('git config --global user.email "acejilam@vackbot.com"')
os.system('git config --global user.name  "acejilam"')

# git log --graph --pretty=format:'%Cred%h%Creset - %at -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
