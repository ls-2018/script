#!/usr/bin/env zsh

apt install wget -y

wget https://cf.ghproxy.cc/https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 19 al
ln -sf /usr/bin/clang-19 /usr/bin/clang
ln -sf /usr/bin/clang++-19 /usr/bin/clang++
ln -sf /usr/bin/clang-cpp-19 /usr/bin/clang-cpp

apt-get install -y curl build-essential gcc make git pkg-config libssl-dev
apt-get install -y apt-transport-https ca-certificates curl jq build-essential
apt-get install -y libpcap-dev libbpf-dev libbfd-dev binutils-dev
apt-get install -y linux-tools-common linux-tools-$(uname -r) bpfcc-tools
apt-get install -y python3-pip
apt-get install -y linux-headers-$(uname -r) lldb lld gcc-multilib gcc

sudo ln -s /usr/include/$(arch)-linux-gnu/asm /usr/include/asm

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "x86_64" = $(arch) ]; then

    wget -O /usr/bin/ecli https://cf.ghproxy.cc/https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli
    wget -O /usr/bin/ecc https://cf.ghproxy.cc/https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-x86_64
else
    wget -O /usr/bin/ecc https://cf.ghproxy.cc/https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-aarch64
    wget -O /usr/bin/ecli https://cf.ghproxy.cc/https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli-aarch64
fi
chmod +x /usr/bin/ec*

apt-get install -y bpftrace

# libbpf-dev 可以替换为:
# git clone https://github.com/libbpf/libbpf.git
# cd libbpf/src && BUILD_STATIC_ONLY=y make install && cd - && rm -rf libbpf

# bcc
apt-get install zip bison build-essential cmake flex git libedit-dev zlib1g-dev liblzma-dev arping netperf iperf libpolly-19-dev libelf-dev libclang-19-dev

git clone https://github.com/iovisor/bcc.git
mkdir bcc/build
cd bcc/build
cmake .. -DCMAKE_PREFIX_PATH=/usr/lib/llvm-19/
make -j $(nproc)
sudo make install
cmake -DPYTHON_CMD=python3 -DCMAKE_PREFIX_PATH=/usr/lib/llvm-19/ .. # build python3 binding
pushd src/python/
make -j $(nproc)
sudo make install
popd

git clone https://github.com/brendangregg/perf-tools.git /perf-tools

cat <<EOF >>/etc/profile
export PATH=\$PATH:/perf-tools/bin
EOF

cat <<EOF >>$HOME/.bashrc
export PATH=\$PATH:/perf-tools/bin
EOF
