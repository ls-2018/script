set -ex

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "amd64" = ${ARCH} ]; then
	cp /resources/eunomia-bpf/amd64/ecli /usr/bin/ecli
	cp /resources/eunomia-bpf/amd64/ecc /usr/bin/ecc

	cat /resources/tar/amd64/retsnoop-v0.10.1-amd64.tar.gz | tar -zxvf - && chmod +x ./retsnoop && mv retsnoop /usr/bin/
	cat /resources/tar/amd64/pwru-linux-amd64.tar.gz | tar -zxvf - && chmod +x ./pwru && mv pwru /usr/bin/
else

	cp /resources/eunomia-bpf/arm64/ecli /usr/bin/ecli
	cp /resources/eunomia-bpf/arm64/ecc /usr/bin/ecc

	cat /resources/tar/arm64/retsnoop-v0.10.1-arm64.tar.gz | tar -zxvf - && chmod +x ./retsnoop && mv retsnoop /usr/bin/
	cat /resources/tar/arm64/pwru-linux-arm64.tar.gz | tar -zxvf - && chmod +x ./pwru && mv pwru /usr/bin/

fi

chmod +x /usr/bin/ec*

apt install wget -y

cd ~

cp /resources/others/llvm.sh .
chmod +x llvm.sh

LLVM_VERSION=$(cat llvm.sh | grep CURRENT_LLVM_STABLE= | cut -d= -f2)

# if [[ $(cat /etc/os-release | grep "VERSION_ID") == *"24.04"* ]]; then
#     export LLVM_VERSION=19
# fi

./llvm.sh ${LLVM_VERSION} -m https://mirrors.bfsu.edu.cn/llvm-apt

for file in $(ls /usr/bin | grep "\-${LLVM_VERSION}$"); do
	base=$(echo $file | sed 's/-[0-9]*$//')
	ln -sf "/usr/bin/$file" "/usr/bin/$base"
done

apt-get install -y

# errno -l
#apt install -y linux-tools-generic
apt-get install -y moreutils \
	curl build-essential gcc make git pkg-config libssl-dev \
	apt-transport-https ca-certificates jq build-essential \
	libpcap-dev libbfd-dev binutils-dev \
	linux-tools-common linux-tools-$(uname -r) \
	python3-pip \
	linux-headers-$(uname -r) \
	zip bison build-essential cmake flex \
	zlib1g-dev liblzma-dev arping netperf iperf \
	libelf-dev libedit-dev \
	g++ libfl-dev systemtap-sdt-dev \
	libcereal-dev libgtest-dev libgmock-dev asciidoctor \
	pahole libcurl4-openssl-dev lldb-${LLVM_VERSION} \
	lld-${LLVM_VERSION} liblldb-${LLVM_VERSION}-dev gdb python3-dev zstd libzstd-dev \
	libpolly-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev

apt install libbpf-dev -y
# libbpf-dev 可以替换为:
# cd ~
# cp -rf /resources/3rd/libbpf libbpf
# cd libbpf/src && BUILD_STATIC_ONLY=y make install && cd - && rm -rf libbpf

sudo ln -s /usr/include/$(arch)-linux-gnu/asm /usr/include/asm

# apt-get install -y bpftrace
# cd ~
# cp -rf /resources/3rd/bcc bcc
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
apt-get install bpfcc-tools linux-headers-$(uname -r) -y

# if [[ $(cat /etc/os-release | grep "VERSION_ID") == *"24.04"* ]]; then
#     cd ~
#     cp -rf /resources/3rd/bpftrace bpftrace
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

cp -rf /resources/3rd/perf-tools /perf-tools

echo 'export PATH=$PATH:/perf-tools/bin' | tee -a $HOME/.bash_profile
echo 'export PATH=$PATH:/perf-tools/bin' | tee -a $HOME/.zshenv

cd ~
cp /resources/others/libpcap-1.10.4.tar.gz .
tar -zxvf libpcap-1.10.4.tar.gz
cd libpcap-1.10.4
./configure --disable-rdma --disable-shared --disable-usb --disable-netmap --disable-bluetooth --disable-dbus --without-libnl
make
sudo make install

cd ~
rm -rf ./*
