#!/bin/sh
if [ $# -eq 0 ]; then
	PID=999999
else
	PID=$1
fi

a=$(uname -a)

b="Darwin"
c="centos"
d="ubuntu"
#pstree -p pid
if [[ $a =~ $b ]]; then
	ps -M $1
elif [[ $a =~ $c ]]; then
	echo "centos"
elif [[ $a =~ $d ]]; then
	ps -eLf | grep $1
	echo "ubuntu"
else
	echo $a
fi
