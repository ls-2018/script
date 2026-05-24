#! /usr/bin/env python3

header = ''
s = 0
e = 0
over = False


def find_sublist_index(lst, sublst):
    for i in range(len(lst) - len(sublst) + 1):
        if lst[i:i + len(sublst)] == sublst:
            return i
    return -1  # 未找到返回 -1


def get_index(data):
    index = -1
    if 'AGE' in data:
        index = find_sublist_index(list(data), list("AGE"))
        if index < 0:
            return 0,0
        else:
            return index, len("AGE")
    if 'LASTTRANSITIONTIME' in data:
        index = find_sublist_index(list(data), list("LASTTRANSITIONTIME"))
        if index < 0:
            return 0,0
        else:
            return index, len("LASTTRANSITIONTIME")

    return 0,0

while 1:
    try:
        line = input()
    except:
        exit(0)
    line = line
    if s == 0:
        s,skip = get_index(line)

        header = list(line)
        if ''.join(header[s + skip:]).lstrip(' ') == '':
            over = True
        e = s + len(header[s:]) - len(''.join(header[s + skip:]).lstrip(' '))
    if s == 0:
        print(line)
    else:
        if over:
            print(str(line[:s]))
        else:
            print(str(line[:s]), str(line[e:]))
