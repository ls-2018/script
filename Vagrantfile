
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
      vm.vm.disk :disk, size: "100GB", primary: true
      # vm.vm.box = "gutehall/ubuntu24-04"
      vm.vm.box = "bento/ubuntu-22.04"
      vm.vm.hostname = "vm2404"

      vm.vm.box_check_update = false
      vm.vm.network "private_network",ip: "192.168.33.12",hostname: true
      vm.vm.synced_folder "~/.ssh", "/host_ssh", mount_options:["dmode=777","fmode=666"]
      vm.vm.synced_folder "~/.kube", "/.host_kube"
      vm.vm.synced_folder "~/Desktop/ebpf", "/ebpf", owner: "root", group: "root"
      vm.vm.synced_folder "~/script", "/Users/acejilam/script", mount_options:["dmode=555","fmode=444"]
      vm.vm.provider "vmware_fusion" do |vb|
        vb.gui = false
        vb.linked_clone = false
        vb.memory = 6000
        vb.cpus = 6
      end
      vm.vm.provision "shell", inline: <<-SHELL
        set -x
        bash /Users/acejilam/script/linux-install-tools.sh
        bash /Users/acejilam/script/linux-replace-sources.sh
        bash /Users/acejilam/script/linux-resize-vagrant-disk.sh
        . /Users/acejilam/script/linux-add-env.sh
        # bash /Users/acejilam/script/linux-install-rust.sh
        bash /Users/acejilam/script/linux-install-bpf.sh
        bash /Users/acejilam/script/linux-install-go.sh
        # bash /Users/acejilam/script/linux-install-k8s.sh cilium
      SHELL
    end

    # config.vm.define "vm2004" do |vm|
    #   vm.vm.box = "bento/ubuntu-20.04"
    #   vm.vm.hostname = "vm2004"
    #   vm.vm.box_check_update = false
    #   vm.vm.network "private_network",ip: "192.168.33.11",hostname: true
    #   vm.vm.synced_folder "~/.ssh", "/host_ssh", mount_options:["dmode=775","fmode=664"]
    #   vm.vm.provider "vmware_fusion" do |vb|
    #     vb.gui = false
    #     vb.memory = 1024
    #     vb.cpus = 1
    #   end
    #   vm.vm.provision "shell", inline: <<-SHELL
    #   SHELL
    # end

end
