#!/bin/sh

res=$(git config --global -l | grep 刘硕)

if [[ "$res" == "" ]]; then
	git config --global user.name "刘硕"
	echo Z2l0IGNvbmZpZyAtLWdsb2JhbCB1c2VyLmVtYWlsICJsaXVzaHVvQHpldHl1bi5jb20iCg== | python3 -c 'import base64,os;os.system(base64.b64decode(input()))'
else
	git config --global user.name "acejilam"
	git config --global user.email "acejilam@gmail.com"
fi

python3 -c "import subprocess;print(subprocess.getoutput('git config --global -l').replace('\n', '\r\n'))"
