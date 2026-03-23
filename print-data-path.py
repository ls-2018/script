#!/usr/bin/env python3
import platform

def node():
    if 'M4' in platform.node():
        return '/Users/acejilam/data'
    else:
        return '/Volumes/Tf/'

if __name__ == '__main__':
    print(node())