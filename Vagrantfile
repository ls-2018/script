# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.cnblogs.com/yinzhengjie/p/18257781
# 也可以直接在加一个net

current_hostname = `hostname`.strip

if current_hostname == "Studio.local"
  settings = {
    "vm" => [
      {
        "box_name" => "bento/ubuntu-22.04",
        "name" => "vm2004",
        "hostname" => "vm2004",
        "ip" => "192.168.31.11",
        "memory" => 4096,
        "cpus" => 4
      },
      {
        "box_name" => "bento/ubuntu-22.04",
        "name" => "vm2204",
        "hostname" => "vm2204",
        "ip" => "192.168.31.12",
        "memory" => 4096,
        "cpus" => 4
      },
      {
        "box_name" => "bento/ubuntu-24.04",
        "name" => "vm2404",
        "hostname" => "vm2404",
        "ip" => "192.168.31.13",
        "memory" => 8192,
        "cpus" => 8
      }
    ]
  }
else
  settings = {
    "vm" => [
      {
        "box_name" => "bento/ubuntu-22.04",
        "name" => "vm2004",
        "hostname" => "vm2004",
        "ip" => "192.168.33.11",
        "memory" => 4096,
        "cpus" => 2
      },
      {
        "box_name" => "bento/ubuntu-22.04",
        "name" => "vm2204",
        "hostname" => "vm2204",
        "ip" => "192.168.33.12",
        "memory" => 4096,
        "cpus" => 2
      },
      {
        "box_name" => "bento/ubuntu-24.04",
        "name" => "vm2404",
        "hostname" => "vm2404",
        "ip" => "192.168.33.13",
        "memory" => 4096,
        "cpus" => 4
      }
    ]
  }
end

# 生成hosts内容并赋给变量
hosts_content = []
hosts_content << "\n# Generated hosts entries for Vagrant VMs"
hosts_content << "# Current hostname: #{current_hostname}"
hosts_content << ""

# 遍历settings生成hosts条目
settings['vm'].each do |vm_config|
  hosts_content << "#{vm_config['ip']} #{vm_config['hostname']}"
end

hosts_content << ""
hosts_content << "# Copy the above lines to /etc/hosts"

# 将内容合并为一个字符串
hosts_string = hosts_content.join("\n")

Vagrant.configure("2") do |config|
  settings['vm'].each do |vm_config|
    config.vm.define vm_config['name'] do |vm|
      vm.vm.box = vm_config['box_name']
      vm.vm.hostname = vm_config['hostname']
      vm.vm.box_check_update = false
      # vm.vm.disk :disk, size: "100GB", primary: true

      if current_hostname == "Studio.local"
        vm.vm.network "public_network", ip: vm_config['ip'], hostname: true, bridge: "en1: Wi-Fi"
      else
        vm.vm.network "private_network", ip: vm_config['ip'], hostname: true
      end

      vm.vm.synced_folder ".", "/vagrant", disabled: true
      vm.vm.synced_folder "~/.ssh", "/host_ssh"
      vm.vm.synced_folder "~/.kube", "/host_kube"
      vm.vm.synced_folder "~/script", "/Users/acejilam/script"
      vm.vm.synced_folder "/Volumes/Tf/resources", "/resources"
      vm.vm.synced_folder "/Volumes/Tf/docker_images", "/docker_images"

      vm.vm.synced_folder "~/.cargo/target", "/root/.cargo/target"
      vm.vm.synced_folder "~/.cargo/registry", "/root/.cargo/registry"
      vm.vm.synced_folder "~/.cargo/git", "/root/.cargo/git"

      # brew tap hashicorp/tap
      # brew install hashicorp/tap/hashicorp-vagrant
      # vagrant plugin uninstall vagrant-vmware-fusion
      # vagrant plugin uninstall vagrant-vmware-desktop
      # vagrant plugin uninstall vagrant-virtualbox
      # vagrant plugin install vagrant-vmware-fusion  vagrant-disksize vagrant-sshfs

      vm.vm.provider :vmware_desktop do |vb|
        vb.vmx["memsize"] = vm_config['memory']
        vb.vmx["numvcpus"] = vm_config['cpus']
        vb.vmx["cpuid.coresPerSocket"] = "2"
      end

      vm.vm.provider :virtualbox do |vb|
        vb.memory = vm_config['memory']
        vb.cpus = vm_config['cpus']
      end

      vm.vm.provision "shell", env: {"HOSTS_CONTENT" => hosts_string}, inline: <<-SHELL
        set -ex
        echo "$HOSTS_CONTENT" >> /etc/hosts

        bash /Users/acejilam/script/linux-replace-sources.sh
        bash /Users/acejilam/script/linux-install-tools.sh
        bash /Users/acejilam/script/linux-resize-vagrant-disk.sh
        bash /Users/acejilam/script/linux-install-zsh.sh
        bash /Users/acejilam/script/linux-install-go.sh
        bash /Users/acejilam/script/linux-add-env.sh

        if [[ $(hostname) == "vm2004" ]]; then
          sudo apt-get install nfs-kernel-server rpcbind selinux-utils nfs-common -y
          rm -rf /nfs
          mkdir -p /nfs
#           chown -R nobody:nobody /nfs
          chown -R 65534:65534 /nfs
          echo '/nfs   192.168.0.0/16(rw,async,no_root_squash,no_subtree_check)' > /etc/exports
          exportfs -arv
          showmount -e
          sudo /etc/init.d/nfs-kernel-server start
        fi
        bash /Users/acejilam/script/linux-install-bpf.sh
        if [[ $(hostname) == "vm2404" ]]; then
          bash /Users/acejilam/script/linux-install-rust.sh
          # bash /Users/acejilam/script/linux-install-k8s.sh
          echo "over"
        fi
      SHELL
    end
  end
end
