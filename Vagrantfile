# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.cnblogs.com/yinzhengjie/p/18257781
# 也可以直接在加一个net

settings={
    "vm"=> [
        {
            "box_name"=> "bento/ubuntu-22.04",
            "name"=> "vm2004",
            "hostname"=> "vm2004",
            "ip"=> "192.168.33.11",
            "memory"=> 2048,
            "cpus"=> 2
        },
        {
            "box_name"=> "bento/ubuntu-22.04",
            "name"=> "vm2204",
            "hostname"=> "vm2204",
            "ip"=> "192.168.33.12",
            "memory"=> 2048,
            "cpus"=> 2
        },
        {
            "box_name"=> "bento/ubuntu-24.04",
            "name"=> "vm2404",
            "hostname"=> "vm2404",
            "ip"=> "192.168.33.13",
            "memory"=> 6144,
            "cpus"=> 6
        }
    ]
}


Vagrant.configure("2") do |config|
  settings['vm'].each do |vm_config|
    config.vm.define vm_config['name'] do |vm|

      vm.vm.box = vm_config['box_name']
      vm.vm.box_version = vm_config['box_version']
      vm.vm.hostname = vm_config['hostname']
      vm.vm.box_check_update = false
      vm.vm.disk :disk, size: "100GB", primary: true

      vm.vm.network "private_network",ip: vm_config['ip'], hostname: true
      vm.vm.synced_folder "~/.ssh", "/host_ssh", mount_options:["dmode=777","fmode=666"]
      vm.vm.synced_folder "~/.kube", "/.host_kube"
      vm.vm.synced_folder "~/Desktop/ebpf", "/ebpf", owner: "root", group: "root"
      vm.vm.synced_folder "~/script", "/Users/acejilam/script", mount_options:["dmode=555","fmode=444"]
      vm.vm.synced_folder "~/resources", "/resources"
      vm.vm.synced_folder "~/.docker_images", "/docker_images"

      vm.vm.synced_folder "~/.cargo/target", "/root/.cargo/target"
      vm.vm.synced_folder "~/.cargo/registry", "/root/.cargo/registry"
      vm.vm.synced_folder "~/.cargo/git", "/root/.cargo/git"

      # vagrant plugin install vagrant-vmware-desktop vagrant-disksize
      vm.vm.provider "vmware_fusion" do |vb|
        vb.gui = false
        vb.linked_clone = false
        vb.memory = vm_config['memory']
        vb.cpus = vm_config['cpus']
      end

      vm.vm.provision "shell", inline: <<-SHELL
        set -ex
        bash /Users/acejilam/script/linux-replace-sources.sh
        bash /Users/acejilam/script/linux-install-tools.sh
        bash /Users/acejilam/script/linux-resize-vagrant-disk.sh
        bash /Users/acejilam/script/linux-install-zsh.sh
        bash /Users/acejilam/script/linux-install-go.sh
        . /Users/acejilam/script/linux-add-env.sh
        bash /Users/acejilam/script/linux-install-bpf.sh
        if [[ $(hostname) == "vm2404" ]];then
          bash /Users/acejilam/script/linux-install-rust.sh
          bash /Users/acejilam/script/linux-install-k8s.sh
          echo "over"
        fi
      SHELL
    end
  end
end
