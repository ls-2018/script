#!/bin/sh

res=$(git config --global -l | grep acejilam)

if [[ "$res" != "" ]]; then
    git config --global user.name "刘硕"
    git config --global user.email "liushuo@zetyun.com"
else
    git config --global user.name "acejilam"
    git config --global user.email "acejilam@gmail.com"
fi

python3 -c "import subprocess;print(subprocess.getoutput('git config --global -l').replace('\n', '\r\n'))"
