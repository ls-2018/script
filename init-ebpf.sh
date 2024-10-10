#! /usr/bin/env zsh
set -ex
limactl delete learning-ebpf -f

cp -rf ~/script/learning-ebpf.yaml /tmp/learning-ebpf.yaml

gsed -i "s#PWD#$(pwd)#" /tmp/learning-ebpf.yaml

limactl start /tmp/learning-ebpf.yaml

limactl shell learning-ebpf
