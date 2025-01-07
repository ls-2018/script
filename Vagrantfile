
# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.cnblogs.com/yinzhengjie/p/18257781
# 也可以直接在加一个net

settings={
    "vm"=> [
        # {
        #   "box_name"=> "bento/ubuntu-18.04",
        #     "name"=> "1804",
        #     "ip"=> "192.168.33.10",
        #     "memory"=> 2048,
        #     "cpus"=> 2
        # },
    ]
}
# Vagrant.configure("2") do |config|
#   settings['vm'].each do |vm_config|
#     config.vm.define vm2404 do |vm|
#     end
#   end
# end

Vagrant.configure("2") do |config|
    config.vm.define "vm2404" do |vm|
      vm.vm.box = "gutehall/ubuntu24-04"
      vm.vm.hostname = "vm2404"
      vm.vm.box_check_update = false
      vm.vm.network "private_network",ip: "192.168.33.12",hostname: true
      vm.vm.synced_folder "~/.ssh", "/host_ssh", mount_options:["dmode=775","fmode=664"]
      vm.vm.synced_folder "~/.kube", "/.host_kube"
      vm.vm.synced_folder "~/Desktop/ebpf", "/ebpf"
      vm.vm.synced_folder "~/script", "/Users/acejilam/script", mount_options:["dmode=775","fmode=555"]
      vm.vm.provider "vmware_fusion" do |vb|
        vb.gui = false
        vb.memory = 6000
        vb.cpus = 6
      end
      vm.vm.provision "shell", inline: <<-SHELL
        echo 'export GITHUB_PROXY=https://ghproxy.cn' | tee -a /etc/profile
        echo 'export GITHUB_PROXY=https://ghproxy.cn' | tee -a $HOME/.bashrc
        source /etc/profile
        curl -sfL ${GITHUB_PROXY}/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-tools.sh | bash
        echo 'source /Users/acejilam/script/customer_script.sh' | tee -a /etc/profile
        echo 'source /Users/acejilam/script/customer_script.sh' | tee -a $HOME/.bashrc
        source /etc/profile
        # curl -L ${GITHUB_PROXY}/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-rust.sh | bash
        curl -sfL ${GITHUB_PROXY}/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-bpf.sh | bash
        curl -sfL ${GITHUB_PROXY}/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-go.sh | bash
        curl -sfL ${GITHUB_PROXY}/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-k8s.sh | bash -s cilium
      SHELL
    end

    config.vm.define "vm2004" do |vm|
      vm.vm.box = "bento/ubuntu-20.04"
      vm.vm.hostname = "vm2004"
      vm.vm.box_check_update = false
      vm.vm.network "private_network",ip: "192.168.33.11",hostname: true
      vm.vm.synced_folder "~/.ssh", "/host_ssh", mount_options:["dmode=775","fmode=664"]
      vm.vm.provider "vmware_fusion" do |vb|
        vb.gui = false
        vb.memory = 1024
        vb.cpus = 1
      end
      vm.vm.provision "shell", inline: <<-SHELL
        echo 'export GITHUB_PROXY=https://ghproxy.cn' | tee -a /etc/profile
        echo 'export GITHUB_PROXY=https://ghproxy.cn' | tee -a $HOME/.bashrc
        source /etc/profile
        curl -sfL ${GITHUB_PROXY}/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-tools.sh | bash
        source /etc/profile
      SHELL
    end

end
