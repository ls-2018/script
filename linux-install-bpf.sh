#!/usr/bin/env zsh

apt install wget -y

# wget https://apt.llvm.org/llvm.sh
# chmod +x llvm.sh
# sudo ./llvm.sh 19 al

wget https://mirrors.bfsu.edu.cn/llvm-apt/llvm.sh
chmod +x llvm.sh
./llvm.sh 19 -m https://mirrors.bfsu.edu.cn/llvm-apt

for file in $(ls /usr/bin | grep '\-19$'); do
    base=$(echo $file | sed 's/-[0-9]*$//')
    ln -sf "/usr/bin/$file" "/usr/bin/$base"
done

apt-get install -y curl build-essential gcc make git pkg-config libssl-dev \
    apt-transport-https ca-certificates curl jq build-essential \
    libpcap-dev libbpf-dev libbfd-dev binutils-dev \
    linux-tools-common linux-tools-$(uname -r) bpfcc-tools \
    python3-pip \
    linux-headers-$(uname -r) lldb lld gcc

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
apt-get install -y zip bison build-essential cmake flex git \
    zlib1g-dev liblzma-dev arping netperf iperf \
    libpolly-19-dev libelf-dev libclang-19-dev libedit-dev

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
