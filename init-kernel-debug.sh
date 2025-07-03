# https://hackcpp.github.io/other/6%20linux_kernel_debug.html#%E7%8E%AF%E5%A2%83%E5%87%86%E5%A4%87
apt install gdb-multiarch -y

base_dir=/root

compile_linux() {
    # shellcheck disable=SC2164
    cd $base_dir
    # wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.15.4.tar.xz
    tar -xf linux-6.15.4.tar.xz
    # shellcheck disable=SC2164
    cd linux-6.15.4
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
    make -j$(nproc) Image

    ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

    # 拷贝编译好的镜像备用
    cp vmlinux ../
    cp arch/${ARCH}/boot/Image ../
}

compile_fs() {
    # shellcheck disable=SC2164
    cd $base_dir
    wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
    tar -xvf busybox-1.36.1.tar.bz2
    # shellcheck disable=SC2164
    cd busybox-1.36.1

    make menuconfig
    #-> Settings
    #　--- Build Options
    #　　[*] Build static binary (no shared libs) #进行静态编译 (CONFIG_STATIC=y)

    sed -i 's/CONFIG_TC=y/CONFIG_TC=n/g' .config
    # 安装完成后生成的相关文件会在 _install 目录下
    make && make install
    # shellcheck disable=SC2164
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

fs() {
    wget https://buildroot.org/downloads/buildroot-2024.02.1.tar.gz
    tar -xf buildroot-2024.02.1.tar.gz

    make qemu_aarch64_virt_defconfig
    make -j$(nproc)

    wget https://cdimage.ubuntu.com/ubuntu-base/noble/daily/20250629/noble-base-arm64.tar.gz
    mkdir rootfs-ubuntu
    tar -xzf noble-base-arm64.tar.gz -C rootfs-ubuntu

}

run() {
    qemu-system-aarch64 -machine help
    ps -ef | grep qemu | awk -F ' ' '{print $2}' | xargs -I F kill -9 F

    qemu-system-aarch64 \
        -kernel ./Image \
        -machine virt \
        -cpu cortex-a57 \
        -initrd ./rootfs.img \
        -append "console=ttyAMA0 nokaslr" \
        -s -S -nographic
}

compile_linux
compile_fs
install_qemu

# ps -ef |grep qemu|awk -F ' ' '{print $2}'|xargs -I F kill -9 F
# gdb-multiarch -ex 'target remote :1234' vmlinux
# break start_kernel

M2() {
    sudo apt update
    sudo apt install -y git build-essential libncurses-dev flex bison unzip bc

    # 获取最新版 Buildroot
    git clone https://github.com/buildroot/buildroot.git
    cd buildroot
    make qemu_aarch64_virt_defconfig
    make -j$(nproc)

    qemu-system-aarch64 \
        -M virt \
        -cpu cortex-a53 \
        -nographic \
        -kernel output/images/Image \
        -initrd output/images/rootfs.cpio \
        -append "console=ttyAMA0"

    export PATH=$(echo "$PATH" | tr ':' '\n' | grep -vE '^(\.|./)$' | paste -sd:)

}
