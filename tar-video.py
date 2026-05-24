#!/usr/bin/env python3
import os
import shutil

source_dir = '/Users/acejilam/Desktop/MIJIA_RECORD_VIDEO'

target_dir = source_dir + '.bak'
os.makedirs(target_dir, exist_ok=True)


def mv():
    for item in os.listdir(source_dir):
        if not item.startswith('2'):
            continue
        year = item[:4]
        month = item[4:6]
        day = item[6:8]
        dset_dir = os.path.join(target_dir, f'{year}-{month}-{day}')
        os.makedirs(dset_dir, exist_ok=True)
        os.system(f'mv {source_dir}/{item}/* {dset_dir}')


def tar():
    for item in os.listdir(target_dir):
        try:
            if item.endswith('.tar'):
                # os.remove(f'{target_dir}/{item}.tar')
                continue
        except:
            pass
        os.system(f'tar -cvf {target_dir}/{item}.tar {target_dir}/{item}/')
        shutil.rmtree(os.path.join(target_dir, item), ignore_errors=True)


if __name__ == '__main__':
    # mv()
    tar()
