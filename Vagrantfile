# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.cnblogs.com/yinzhengjie/p/18257781
# 也可以直接在加一个net

settings={
    "box_name"=> "gutehall/ubuntu24-04",
    "vm"=> [
        # {
        #     "name"=> "controlplane",
        #     "ip"=> "192.168.33.31",
        #     "memory"=> 2048,
        #     "cpus"=>2
        # },
        # {
        #     "name"=> "node01",
        #     "ip"=> "192.168.33.32",
        #     "memory"=> 2048,
        #     "cpus"=> 1
        # },
        # {
        #     "name"=> "node02",
        #     "ip"=> "192.168.33.33",
        #     "memory"=> 2048,
        #     "cpus"=> 1
        # },
        {
            "name"=> "ebpf",
            "ip"=> "192.168.33.10",
            "memory"=> 4096,
            "cpus"=> 4
        }
    ]
}


Vagrant.configure("2") do |config|
  settings['vm'].each do |vm_config|
    config.vm.define vm_config['name'] do |vm|
      vm.vm.box = settings['box_name']
      vm.vm.box_version = settings['box_version']
      vm.vm.hostname = vm_config['name']
      vm.vm.box_check_update = false
      vm.vm.network "private_network",ip: vm_config['ip'],hostname: true
      vm.vm.synced_folder "~/.ssh", "/host_ssh", mount_options:["dmode=775","fmode=664"]

      vm.vm.provider "vmware_fusion" do |vb|
        vb.gui = false
        vb.memory = vm_config['memory']
        vb.cpus = vm_config['cpus']
      end

      vm.vm.provision "shell", inline: <<-SHELL
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
