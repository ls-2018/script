#! /usr/bin/env zsh
set -x

name=${1-learning-ebpf}

limactl delete $name -f

cp -rf ~/script/learning-ebpf.yaml /tmp/$name.yaml

gsed -i "s#PWD#$(pwd)#" /tmp/$name.yaml
gsed -i "s#HOSTNAME#${name}#" /tmp/$name.yaml


limactl start /tmp/$name.yaml # --debug --log-level=debug

limactl shell $name sudo bash -c "cd $(pwd) && bash"
