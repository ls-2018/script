#!/usr/bin/env zsh
apt install wget -y

apt-get install -y apt-transport-https ca-certificates curl clang llvm jq build-essential gcc
apt-get install -y libelf-dev libpcap-dev libbfd-dev binutils-dev build-essential make
apt-get install -y linux-tools-common linux-tools-$(uname -r) bpfcc-tools libbpf-dev
apt-get install -y python3-pip

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "x86_64" = $(arch) ]; then
    wget -O /usr/bin/ecli https://files.m.daocloud.io/github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli
    wget -O /usr/bin/ecc https://files.m.daocloud.io/github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-x86_64
else
    wget -O /usr/bin/ecc https://files.m.daocloud.io/github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-aarch64
    wget -O /usr/bin/ecli https://files.m.daocloud.io/github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli-aarch64
fi
chmod +x /usr/bin/ec*
