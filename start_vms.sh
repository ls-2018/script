#!/usr/bin/env zsh

cat >Vagrantfile <<EOF

# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.cnblogs.com/yinzhengjie/p/18257781
# 也可以直接在加一个net

settings={
    "vm"=> [
        {
          "box_name"=> "bento/ubuntu-18.04",
            "name"=> "1804",
            "ip"=> "192.168.33.10",
            "memory"=> 2048,
            "cpus"=> 2
        },
        {
          "box_name"=> "bento/ubuntu-20.04",
            "name"=> "2004",
            "ip"=> "192.168.33.11",
            "memory"=> 2048,
            "cpus"=> 2
        },
        {
            "box_name"=> "gutehall/ubuntu24-04",
            "name"=> "2404",
            "ip"=> "192.168.33.12",
            "memory"=> 2048,
            "cpus"=> 2
        }
    ]
}


Vagrant.configure("2") do |config|
  settings['vm'].each do |vm_config|
    config.vm.define vm_config['name'] do |vm|
      vm.vm.box = vm_config['box_name']
      vm.vm.box_version = settings['box_version']
      vm.vm.hostname = vm_config['name']
      vm.vm.box_check_update = false
      vm.vm.network "private_network",ip: vm_config['ip'],hostname: true
      vm.vm.synced_folder "~/.ssh", "/host_ssh", mount_options:["dmode=775","fmode=664"]
      vm.vm.synced_folder "~/Desktop/ebpf", "/ebpf"

      vm.vm.provider "vmware_fusion" do |vb|
        vb.gui = false
        vb.memory = vm_config['memory']
        vb.cpus = vm_config['cpus']
      end

      vm.vm.provision "shell", inline: <<-SHELL
        mkdir -p ~/.ssh && apt update && apt install curl git make cmake htop -y
        cat /host_ssh/id_ed25519.pub > ~/.ssh/authorized_keys
        sudo sed -i 's/^#* *\\(PermitRootLogin\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
        sudo sed -i 's/^#* *\\(PasswordAuthentication\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
        ufw disable
        systemctl restart sshd.service
        echo -e "root\nroot" | (passwd root)
        touch ~/.hushlogin

        echo 'nameserver 114.114.114.114' > /etc/resolv.conf
        # git config --global url."https://gitclone.com/".insteadOf https://
        git config --global url."https://cf.ghproxy.cc/https://github.com".insteadOf "https://github.com"
        # git config --global --unset url."https://cf.ghproxy.cc/https://github.com".insteadOf "https://github.com"
        curl -L https://cf.ghproxy.cc/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-replace-sources.sh | bash
        curl -L https://cf.ghproxy.cc/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-rust.sh | bash
        curl -L https://cf.ghproxy.cc/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-bpf.sh | bash
        curl -L https://cf.ghproxy.cc/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-go.sh | bash

      SHELL
    end
  end
end

EOF
set -ex
rm -rf .vagrant

vagrant global-status --prune

# 定义虚拟机名称数组
vms=("1804" "2004" "2404")

# 使用并发执行 vagrant up 命令
for vm in "${vms[@]}"; do
  vagrant destroy "$vm" --force
  vagrant up "$vm" &
done

# 等待所有后台任务完成
wait