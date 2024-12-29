#!/usr/bin/env zsh
set -ex
apt install wget -y

# wget https://apt.llvm.org/llvm.sh
# chmod +x llvm.sh
# sudo ./llvm.sh 19 al
cd ~
wget https://mirrors.bfsu.edu.cn/llvm-apt/llvm.sh
chmod +x llvm.sh
./llvm.sh 19 -m https://mirrors.bfsu.edu.cn/llvm-apt

for file in $(ls /usr/bin | grep '\-19$'); do
    base=$(echo $file | sed 's/-[0-9]*$//')
    ln -sf "/usr/bin/$file" "/usr/bin/$base"
done
# errno -l
apt-get install -y moreutils \
    curl build-essential gcc make git pkg-config libssl-dev \
    apt-transport-https ca-certificates jq build-essential \
    libpcap-dev libbfd-dev binutils-dev \
    linux-tools-common linux-tools-$(uname -r) bpfcc-tools \
    python3-pip \
    linux-headers-$(uname -r) lldb lld \
    zip bison build-essential cmake flex \
    zlib1g-dev liblzma-dev arping netperf iperf \
    libpolly-19-dev libelf-dev libclang-19-dev libedit-dev \
    g++ libfl-dev systemtap-sdt-dev \
    libcereal-dev libgtest-dev libgmock-dev asciidoctor \
    pahole libcurl4-openssl-dev liblldb-dev gdb

# libbpf-dev 可以替换为:
cd ~
git clone https://github.com/libbpf/libbpf.git
cd libbpf/src && BUILD_STATIC_ONLY=y make install && cd - && rm -rf libbpf

sudo ln -s /usr/include/$(arch)-linux-gnu/asm /usr/include/asm

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "x86_64" = $(arch) ]; then

    wget -O /usr/bin/ecli https://cf.ghproxy.cc/https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli
    wget -O /usr/bin/ecc https://cf.ghproxy.cc/https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-x86_64
    wget -O - https://cf.ghproxy.cc/https://github.com/anakryiko/retsnoop/releases/download/v0.10.1/retsnoop-v0.10.1-amd64.tar.gz | tar -zxvf - && chmod +x ./retsnoop && mv retsnoop /usr/bin/
    wget -O - https://cf.ghproxy.cc/https://github.com/cilium/pwru/releases/download/v1.0.9/pwru-linux-amd64.tar.gz | tar -zxvf - && chmod +x ./pwru && mv pwru /usr/bin/

else
    wget -O /usr/bin/ecc https://cf.ghproxy.cc/https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecc-aarch64
    wget -O /usr/bin/ecli https://cf.ghproxy.cc/https://github.com/eunomia-bpf/eunomia-bpf/releases/download/v1.0.27/ecli-aarch64
    wget -O - https://cf.ghproxy.cc/https://github.com/anakryiko/retsnoop/releases/download/v0.10.1/retsnoop-v0.10.1-arm64.tar.gz | tar -zxvf - && chmod +x ./retsnoop && mv retsnoop /usr/bin/
    wget -O - https://cf.ghproxy.cc/https://github.com/cilium/pwru/releases/download/v1.0.9/pwru-linux-arm64.tar.gz | tar -zxvf - && chmod +x ./pwru && mv pwru /usr/bin/

fi
chmod +x /usr/bin/ec*
cd ~
git clone https://github.com/iovisor/bpftrace
git config --global --unset http.postBuffer
cp -R bpftrace bpftrace_scz
mkdir bpftrace_scz/build
cd bpftrace_scz/build
cmake .. -DCMAKE_BUILD_TYPE=Release -DALLOW_UNSAFE_PROBE:BOOL=ON -DCMAKE_PREFIX_PATH=/usr/lib/llvm-19/
make -j8
make install
bpftrace --info 2>&1 | grep bfd

# apt-get install -y bpftrace
cd ~

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

cd ~
wget https://cf.ghproxy.cc/https://www.tcpdump.org/release/libpcap-1.10.4.tar.gz
tar -zxvf libpcap-1.10.4.tar.gz
cd libpcap-1.10.4
./configure --disable-rdma --disable-shared --disable-usb --disable-netmap --disable-bluetooth --disable-dbus --without-libnl
make
sudo make install

rm -rf ./*
