#!/usr/bin/env bash

set -x

# https://hackcpp.github.io/other/6%20linux_kernel_debug.html#%E7%8E%AF%E5%A2%83%E5%87%86%E5%A4%87
apt install gdb-multiarch libelf-dev -y

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "当前脚本所在目录: $base_dir"

ARCH=$(arch | sed s/aarch64/arm64/)
version=6.15.4

image=""
qemu=""
if [ "$ARCH" == "arm64" ]; then
	image="Image"
	qemu="qemu-system-aarch64"
elif [ "$ARCH" == "x86_64" ]; then
	image="bzImage"
	qemu="qemu-system-x86_64"
else
	echo "Unsupported architecture: $ARCH"
	exit 1
fi

compile_linux() {
	cd $base_dir
	if [ -f linux-${version}.tar.xz ]; then
		echo "linux-${version} already exists, skipping download."
		rm -rf linux-${version} || true
	else
		echo "Downloading linux-${version}..."
		wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz
	fi

	tar -xf linux-${version}.tar.xz
	cd linux-${version}
	# Kernel hacking --->
	#  Compile-time checks and compiler options --->
	#    [ ] Debug information
	#  Generic Kernel Debugging Instruments  --->
	#    [*] KGDB: kernel debugger  --->
	make mrproper
	# 配置内核（使用默认配置）
	make defconfig #运行结束生成 .config 文件在当前目录

	grep CONFIG_DEBUG_INFO .config

	# 生成调试符号并编译内核
	# vmlinux: 一个包含调试符号的未压缩内核映像，GDB 调试时会用到它,在当前目录linux-6.10.6
	# bzImage: 编译后的镜像 bzImage, 路径： linux-6.10.6/arch/x86/boot/bzImage
	make -j$(nproc) vmlinux
	make -j$(nproc) ${image}
}

compile_fs() {
	cd $base_dir
	if [ -f busybox-1.36.1.tar.bz2 ]; then
		echo "busybox-1.36.1 already exists, skipping download."
		rm -rf busybox-1.36.1
	else
		echo "Downloading busybox-1.36.1..."
		wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
	fi
	tar -xvf busybox-1.36.1.tar.bz2
	cd busybox-1.36.1

	make menuconfig
	#-> Settings
	#　--- Build Options
	#　　[*] Build static binary (no shared libs) #进行静态编译 (CONFIG_STATIC=y)

	sed -i 's/CONFIG_TC=y/CONFIG_TC=n/g' .config
	# 安装完成后生成的相关文件会在 _install 目录下
	make && make install
	cd _install
	mkdir proc
	mkdir sys

	cat >init <<EOF
#!/bin/sh
echo "{==DBG==} INIT SCRIPT"
mkdir /tmp
mount -t proc none /proc
mount -t sysfs none /sys
mount -t debugfs none /sys/kernel/debug
mount -t tmpfs none /tmp

mdev -s
echo -e "{==DBG==} Boot took \$(cut -d' ' -f1 /proc/uptime) seconds"

# normal user
setsid /bin/cttyhack setuidgid 1000 /bin/sh
EOF

	# init 为内核启动的初始化程序
	# 必须设置成可执行文件
	chmod +x init

	# 打包启动的文件系统
	find . | cpio -o --format=newc >../../rootfs.img
}

install_qemu() {
	# 安装 QEMU
	sudo apt-get install qemu-system git libncurses-dev fakeroot build-essential ncurses-dev xz-utils libssl-dev bc
}

run() {
	cd $base_dir
	# qemu-system-aarch64 -machine help
	ps -ef | grep qemu | awk -F ' ' '{print $2}' | xargs -I F kill -9 F
	cd linux-${version}
	echo 'gdb /root/linux-6.15.4/vmlinux -ex "target remote :1234" -ex "break start_kernel"'
	${qemu} \
		-kernel ./arch/${ARCH}/boot/${image} \
		-machine q35 \
		-smp 1 \
		-cpu cortex-a57 \
		-initrd ../rootfs.img \
		-append "nokaslr console=ttyS0" \
		-s -S -nographic
}

# compile_linux
# compile_fs
# install_qemu
# run

buildroot() {
	sudo apt update
	sudo apt install -y qemu-system git build-essential libncurses-dev flex bison unzip bc

	# 获取最新版 Buildroot
	git clone https://github.com/buildroot/buildroot.git -b 2025.05
	cd buildroot
	make qemu_aarch64_virt_defconfig
	env PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin make -j$(nproc)
	cd ./output/images
	sed -i 's/-nographic/-nographic -s -S/g' start-qemu.sh
	sed -i 's/rootwait/nokaslr rootwait/g' start-qemu.sh
	echo "✈️ ✈️ ✈️ ✈️ ✈️ ✈️ ✈️ ✈️ ✈️"
	echo "ps -ef |grep qemu-system |awk -F ' ' '{print $2}'|xargs -I F kill -9 F"
	echo "gdb-multiarch -ex 'target remote :1234' ./linux-6.12.27/vmlinux"
	echo "break start_kernel"
	echo "c"
	echo "✈️ ✈️ ✈️ ✈️ ✈️ ✈️ ✈️ ✈️ ✈️"

	bash ./start-qemu.sh
}

if [ "$1" == "" ]; then
	echo "Usage: $0 [buildroot|default]"
	echo "If you want to use buildroot, please run: $0 buildroot"
	echo "Otherwise, it will compile the Linux kernel and BusyBox."
	exit 1
fi

if [ "$1" == "buildroot" ]; then
	buildroot
else
	compile_linux
	compile_fs
	install_qemu
	run
fi

# sudo bpftrace -e 'kprobe:vfs_write{  printf("PID %d (%s) vfs_write(fd=%d, buf=0x%x, count=%d)\n", pid, comm, arg0, arg1, arg2);}'

# qemu-system-aarch64 -machine type=q35,accel=hvf -kernel ./bzImage -initrd  ./rootfs_root.img -append "nokaslr console=ttyS0" -s c
