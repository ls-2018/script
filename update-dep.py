#!/usr/bin/env python3
import os
import sys

pwd = sys.argv[1]

for root, dirs, files in os.walk(pwd):
    for file in files:
        if file == 'go.mod':
            os.system(f'cd {root} && go mod tidy && go mod vendor')
