#!/usr/bin/env bash

set -xv
export DEBIAN_FRONTEND=noninteractive

apt-get install -y build-essential dkms linux-headers-$(uname -r)

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "amd64" = ${ARCH} ]; then
	cp /Volumes/Tf/resources/eunomia-bpf/amd64/ecli /usr/bin/ecli
	cp /Volumes/Tf/resources/eunomia-bpf/amd64/ecc /usr/bin/ecc

	cat /Volumes/Tf/resources/tar/amd64/retsnoop-v0.10.1-amd64.tar.gz | tar -zxvf - && chmod +x ./retsnoop && mv retsnoop /usr/bin/
	cat /Volumes/Tf/resources/tar/amd64/pwru-linux-amd64.tar.gz | tar -zxvf - && chmod +x ./pwru && mv pwru /usr/bin/
else
	cp /Volumes/Tf/resources/eunomia-bpf/arm64/ecli /usr/bin/ecli
	cp /Volumes/Tf/resources/eunomia-bpf/arm64/ecc /usr/bin/ecc

	cat /Volumes/Tf/resources/tar/arm64/retsnoop-v0.10.1-arm64.tar.gz | tar -zxvf - && chmod +x ./retsnoop && mv retsnoop /usr/bin/
	cat /Volumes/Tf/resources/tar/arm64/pwru-linux-arm64.tar.gz | tar -zxvf - && chmod +x ./pwru && mv pwru /usr/bin/
fi

chmod +x /usr/bin/ec*

apt install wget -y

cd ~

cp /Volumes/Tf/resources/others/llvm.sh .
chmod +x llvm.sh
cp -rf /Volumes/Tf/resources/others/llvm-snapshot.gpg.key /etc/apt/trusted.gpg.d/apt.llvm.org.asc

LLVM_VERSION=$(cat llvm.sh | grep CURRENT_LLVM_STABLE= | cut -d= -f2)

if [[ $(cat /etc/os-release | grep "VERSION_ID") == *"24.04"* ]]; then
    export LLVM_VERSION=19
fi
if [[ $(cat /etc/os-release | grep "VERSION_ID") == *"22.04"* ]]; then
    export LLVM_VERSION=18
fi

# ./llvm.sh ${LLVM_VERSION} -m https://mirrors.bfsu.edu.cn/llvm-apt
# ./llvm.sh ${LLVM_VERSION} -m https://mirrors.tuna.tsinghua.edu.cn/llvm-apt/
./llvm.sh ${LLVM_VERSION} 

for file in $(ls /usr/bin | grep "\-${LLVM_VERSION}$"); do
	base=$(echo $file | sed 's/-[0-9]*$//')
	ln -sf "/usr/bin/$file" "/usr/bin/$base"
done


# errno -l
#apt install -y linux-tools-generic

# build-essential				:包括 GCC 编译器、基本库和像 make 这样的构建相关工具
# linux-tools-$(uname -r) 		:内核级开发、性能分析和故障排除的工具 , 包含perf
apt install pkg-config -y
apt-get install -y \
	moreutils \
	curl \
	git \
	libssl-dev \
	apt-transport-https \
	ca-certificates jq \
	libpcap-dev \
	libbfd-dev \
	binutils-dev \
	linux-tools-common \
	linux-tools-$(uname -r) \
	linux-tools-generic \
	python3-pip \
	zip \
	bison \
	cmake flex \
	zlib1g-dev \
	liblzma-dev \
	arping \
	netperf \
	iperf \
	libelf-dev \
	libedit-dev \
	g++ \
	libfl-dev \
	systemtap-sdt-dev \
	libcereal-dev \
	libgtest-dev \
	libgmock-dev \
	asciidoctor \
	pahole \
	libcurl4-openssl-dev \
	lldb-${LLVM_VERSION} \
	lld-${LLVM_VERSION} \
	liblldb-${LLVM_VERSION}-dev \
	gdb \
	python3-dev \
	zstd \
	libzstd-dev \
	libpolly-${LLVM_VERSION}-dev \
	libclang-${LLVM_VERSION}-dev \
	llvm-${LLVM_VERSION}-dev \
	pkgconf \
	bc \
	rsync

# rm $(which bpftool)
# ln -s /usr/lib/linux-tools-$(uname -r | sed 's/-generic//')/bpftool /usr/local/bin/bpftool

# eBPF 程序和映射交互的低级接口。它提供了加载、验证和执行 eBPF 程序的功能。
apt install libbpf-dev -y
# libbpf-dev 可以替换为:
# cd ~
# cp -rf /Volumes/Tf/resources/3rd/libbpf libbpf
# cd libbpf/src && BUILD_STATIC_ONLY=y make install && cd - && rm -rf libbpf

# 为多种架构编译和构建软件  studio 安装出错
# apt install gcc-multilib -y
apt install musl-tools -y

sudo ln -s /usr/include/$(arch)-linux-gnu/asm /usr/include/asm

# apt-get install -y bpftrace
# cd ~
# cp -rf /Volumes/Tf/resources/3rd/bcc bcc
# cd bcc
# git submodule update --init --recursive
# mkdir build
# cd build
# cmake .. -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VERSION}/
# make -j $(nproc)
# sudo make install
# # build python3 binding
# cmake -DPYTHON_CMD=python3 -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VERSION}/ ..
# pushd src/python/
# make -j $(nproc)
# sudo make install
# popd

apt-get install bpfcc-tools -y

# if [[ $(cat /etc/os-release | grep "VERSION_ID") == *"24.04"* ]]; then
#     cd ~
#     cp -rf /Volumes/Tf/resources/3rd/bpftrace bpftrace
#     cd bpftrace && git submodule update --init --recursive && cd -
#     cp -R bpftrace bpftrace_scz
#     mkdir bpftrace_scz/build
#     cd bpftrace_scz/build
#     cmake .. -DCMAKE_BUILD_TYPE=Release -DALLOW_UNSAFE_PROBE:BOOL=ON -DCMAKE_PREFIX_PATH=/usr/lib/llvm-${LLVM_VERSION}/
#     make -j $(nproc)
#     make install
#     bpftrace --info 2>&1 | grep bfd
# else
apt-get install -y bpftrace
# fi

rm -rf /perf-tools && echo 1

cp -rf /Volumes/Tf/resources/3rd/perf-tools /perf-tools

echo 'export PATH=$PATH:/perf-tools/bin' | tee -a $HOME/.bashrc
echo 'export PATH=$PATH:/perf-tools/bin' | tee -a $HOME/.zshrc

cd ~
cp /Volumes/Tf/resources/others/libpcap-1.10.4.tar.gz .
tar -zxvf libpcap-1.10.4.tar.gz
cd libpcap-1.10.4
./configure --disable-rdma --disable-shared --disable-usb --disable-netmap --disable-bluetooth --disable-dbus --without-libnl
make
sudo make install

cd ~
rm -rf ./libpcap-1.10.4 ./libpcap-1.10.4.tar.gz ./llvm.sh ./llvm-snapshot.gpg.key
