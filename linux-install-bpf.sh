#!/usr/bin/env zsh
set -x

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "x86_64" = $(arch) ]; then
    wget --no-verbose -O /usr/bin/ecli ${GITHUB_PROXY}https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli
    wget --no-verbose -O /usr/bin/ecc ${GITHUB_PROXY}https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-x86_64
    wget --no-verbose -O - ${GITHUB_PROXY}https://github.com/anakryiko/retsnoop/releases/download/v0.10.1/retsnoop-v0.10.1-amd64.tar.gz | tar -zxvf - && chmod +x ./retsnoop && mv retsnoop /usr/bin/
    wget --no-verbose -O - ${GITHUB_PROXY}https://github.com/cilium/pwru/releases/download/v1.0.9/pwru-linux-amd64.tar.gz | tar -zxvf - && chmod +x ./pwru && mv pwru /usr/bin/
else
    wget --no-verbose -O /usr/bin/ecc ${GITHUB_PROXY}https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-aarch64
    wget --no-verbose -O /usr/bin/ecli ${GITHUB_PROXY}https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli-aarch64
    wget --no-verbose -O - ${GITHUB_PROXY}https://github.com/anakryiko/retsnoop/releases/download/v0.10.1/retsnoop-v0.10.1-arm64.tar.gz | tar -zxvf - && chmod +x ./retsnoop && mv retsnoop /usr/bin/
    wget --no-verbose -O - ${GITHUB_PROXY}https://github.com/cilium/pwru/releases/download/v1.0.9/pwru-linux-arm64.tar.gz | tar -zxvf - && chmod +x ./pwru && mv pwru /usr/bin/
fi

chmod +x /usr/bin/ec*

apt install wget --no-verbose -y

cd ~
wget --no-verbose https://mirrors.bfsu.edu.cn/llvm-apt/llvm.sh
chmod +x llvm.sh

LLVM_VERSION=$(cat llvm.sh | grep CURRENT_LLVM_STABLE= | cut -d= -f2)

if [[ $(cat /etc/os-release | grep "VERSION_ID") == *"24.04"* ]]; then
    export LLVM_VERSION=19
fi

./llvm.sh ${LLVM_VERSION} -m https://mirrors.bfsu.edu.cn/llvm-apt

for file in $(ls /usr/bin | grep "\-${LLVM_VERSION}$"); do
    base=$(echo $file | sed 's/-[0-9]*$//')
    ln -sf "/usr/bin/$file" "/usr/bin/$base"
done

apt-get install -y libpolly-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev

# errno -l
#apt install -y linux-tools-generic
apt-get install -y moreutils \
    curl build-essential gcc make git pkg-config libssl-dev \
    apt-transport-https ca-certificates jq build-essential \
    libpcap-dev libbfd-dev binutils-dev \
    linux-tools-common linux-tools-$(uname -r) bpfcc-tools \
    python3-pip \
    linux-headers-$(uname -r) lldb lld \
    zip bison build-essential cmake flex \
    zlib1g-dev liblzma-dev arping netperf iperf \
    libelf-dev libedit-dev \
    g++ libfl-dev systemtap-sdt-dev \
    libcereal-dev libgtest-dev libgmock-dev asciidoctor \
    pahole libcurl4-openssl-dev liblldb-dev gdb python3-dev zstd libzstd-dev

# libbpf-dev 可以替换为:

cd ~
git clone https://github.com/libbpf/libbpf.git
cd libbpf/src && BUILD_STATIC_ONLY=y make install && cd - && rm -rf libbpf

sudo ln -s /usr/include/$(arch)-linux-gnu/asm /usr/include/asm

# apt-get install -y bpftrace
cd ~
git clone https://github.com/iovisor/bcc.git
mkdir bcc/build
cd bcc/build
cmake .. -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VERSION}/
make -j $(nproc)
sudo make install
cmake -DPYTHON_CMD=python3 -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VERSION}/ .. # build python3 binding
pushd src/python/
make -j $(nproc)
sudo make install
popd

# cd ~
# git clone https://github.com/iovisor/bpftrace
# cp -R bpftrace bpftrace_scz
# mkdir bpftrace_scz/build
# cd bpftrace_scz/build
# cmake .. -DCMAKE_BUILD_TYPE=Release -DALLOW_UNSAFE_PROBE:BOOL=ON -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VERSION}/
# make -j8
# make install
# bpftrace --info 2>&1 | grep bfd
apt install -y bpftrace

rm -rf /perf-tools && echo 1
git clone https://github.com/brendangregg/perf-tools.git /perf-tools

echo 'export PATH=$PATH:/perf-tools/bin' | tee -a $HOME/.bash_profile

cd ~
wget --no-verbose https://www.tcpdump.org/release/libpcap-1.10.4.tar.gz
tar -zxvf libpcap-1.10.4.tar.gz
cd libpcap-1.10.4
./configure --disable-rdma --disable-shared --disable-usb --disable-netmap --disable-bluetooth --disable-dbus --without-libnl
make
sudo make install

cd ~
rm -rf ./*
