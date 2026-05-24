import os

files = []


def get_file_path(root_path):
    # 获取该目录下所有的文件名称和目录名称
    dir_or_files = os.listdir(root_path)
    for dir_file in dir_or_files:
        # 获取目录或者文件的路径
        dir_file_path = os.path.join(root_path, dir_file)
        # 判断该路径为文件还是路径
        if os.path.isdir(dir_file_path):
            # 递归获取所有文件和目录的路径
            get_file_path(dir_file_path)
        else:
            if dir_file_path.endswith('go'):
                files.append(dir_file_path)


get_file_path('/Users/acejilam/Documents/work/moyun/vlab/basSystem/model')


def db_comment():
    for file in files:
        # if 'payload_file' in file:
        #     pass
        # else:
        #     continue
        flag = False
        with open(file, 'r', encoding='utf8') as f:
            data = f.read()
            if 'gorm:"' in data:
                flag = True
        res = ''
        if flag:
            with open(file, 'r', encoding='utf8') as f:
                for line in f.readlines():
                    demo = line.split(' // ')
                    if len(demo) == 2 and '//' in line and 'gorm:"' in line and not line.startswith('//'):
                        if 'comment' in demo[0]:
                            res += line
                        else:
                            line = line.replace(
                                'gorm:"', 'gorm:"comment:\'%s\'; ' % demo[1].strip())
                            res += line
                    else:
                        res += line
            with open(file, 'w', encoding='utf8') as f:
                f.write(res)
        print(file)


files = []
get_file_path('/Users/acejilam/Documents/work/moyun/vlab/basSystem')


def log():
    for file in files:
        res = ''
        with open(file, 'r', encoding='utf8') as f:
            for line in f.readlines():
                if 'err != nil {' in line:
                    res += line
                    res += 'utils.Logger.Error(err.Error())\n'
                elif 'utils.Logger.Error' in line:
                    continue
                else:
                    res += line
        with open(file, 'w', encoding='utf8') as f:
            f.write(res)
        print(file)


if __name__ == '__main__':
    log()
