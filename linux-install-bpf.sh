#!/usr/bin/env zsh
apt install wget -y

apt-get install -y apt-transport-https ca-certificates curl clang llvm jq build-essential
apt-get install -y libelf-dev libpcap-dev libbpf-dev libbfd-dev libpcap-dev binutils-dev build-essential make git
apt-get install -y linux-tools-common linux-tools-$(uname -r) bpfcc-tools
apt-get install -y python3-pip
apt-get install -y linux-headers-$(uname -r) lldb lld gcc-multilib gcc

sudo ln -s /usr/include/$(arch)-linux-gnu/asm /usr/include/asm

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "x86_64" = $(arch) ]; then
    wget -O /usr/bin/ecli https://files.m.daocloud.io/github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli
    wget -O /usr/bin/ecc https://files.m.daocloud.io/github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-x86_64
else
    wget -O /usr/bin/ecc https://files.m.daocloud.io/github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-aarch64
    wget -O /usr/bin/ecli https://files.m.daocloud.io/github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli-aarch64
fi
chmod +x /usr/bin/ec*

apt-get install -y bpftrace

# libbpf-dev 可以替换为:
# git clone https://github.com/libbpf/libbpf.git
# cd libbpf/src && BUILD_STATIC_ONLY=y make install && cd - && rm -rf libbpf

git clone https://cf.ghproxy.cc/https://github.com/brendangregg/perf-tools.git /perf-tools

cat <<EOF >>/etc/profile
export PATH=\$PATH:/perf-tools/bin
EOF

cat <<EOF >>$HOME/.bashrc
export PATH=\$PATH:/perf-tools/bin
EOF
