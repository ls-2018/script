# -*- mode: ruby -*-
# vi: set ft=ruby :
# https://www.cnblogs.com/yinzhengjie/p/18257781
# 也可以直接在加一个net

current_hostname = `hostname`.strip

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
      "memory" => 6144,
      "cpus" => 4
    }
  ]
}

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

    # 配置 vbguest 插件
    if Vagrant.has_plugin?("vagrant-vbguest")
      config.vbguest.auto_update = false
      config.vbguest.no_remote = false     # 允许下载 VBoxGuestAdditions.iso
      config.vbguest.auto_reboot = true    # 自动重启以应用更新
      config.vbguest.installer_options = {
        run: "always",   # 每次 up/reload 都检查
        allow_install: true
      }
    end

    config.vm.define vm_config['name'] do |vm|
      vm.vm.box = vm_config['box_name']
      vm.vm.hostname = vm_config['hostname']
      vm.vm.box_check_update = false
      vm.vm.disk :disk, size: "200GB", primary: true # virtualbox

      vm.vm.provider "virtualbox" do |vb|
        vb.memory = vm_config["memory"]        # 内存大小 (MB)
        vb.cpus =   vm_config["cpus"]          # CPU 数量
      end

      vm.vm.network "private_network", ip: vm_config["ip"]

      vm.vm.synced_folder ".", "/vagrant", disabled: true
      vm.vm.synced_folder "~/.ssh", "/host_ssh"
      vm.vm.synced_folder "~/.kube", "/host_kube"
      vm.vm.synced_folder "~/script", "/Users/acejilam/script"
      vm.vm.synced_folder "/Volumes/Tf/resources", "/Volumes/Tf/resources"
      vm.vm.synced_folder "/Volumes/Tf/docker_images", "/docker_images"
      vm.vm.synced_folder "/Volumes/Tf/docker-proxy", "/root/docker-proxy"
      vm.vm.synced_folder "~/.cargo/target", "/root/.cargo/target"
      vm.vm.synced_folder "~/.cargo/registry", "/root/.cargo/registry"
      vm.vm.synced_folder "~/.cargo/git", "/root/.cargo/git"

      # brew tap hashicorp/tap
      # brew install hashicorp/tap/hashicorp-vagrant
      # vagrant plugin install vagrant-vmware-desktop vagrant-disksize vagrant-sshfs vagrant-vbguest

      vm.vm.provision "shell", env: {"HOSTS_CONTENT" => hosts_string, "IP" => vm_config["ip"]}, inline: <<-SHELL
        set -v
        echo "$HOSTS_CONTENT" w>> /etc/hosts
        bash /Users/acejilam/script/vagrant-fixip.sh $IP
        bash /Users/acejilam/script/linux-replace-sources.sh
        bash /Users/acejilam/script/linux-install-tools.sh
        bash /Users/acejilam/script/linux-resize-vagrant-disk.sh
        bash /Users/acejilam/script/linux-install-zsh.sh
        bash /Users/acejilam/script/linux-install-go.sh
        bash /Users/acejilam/script/linux-add-env.sh
        bash /Users/acejilam/script/linux-install-bpf.sh

#         if [[ $(hostname) == "vm2004" ]]; then
#           sudo apt-get install nfs-kernel-server rpcbind selinux-utils nfs-common -y
#           rm -rf /nfs
#           mkdir -p /nfs
# #         chown -R nobody:nobody /nfs
#           chown -R 65534:65534 /nfs
#           echo '/nfs   192.168.0.0/16(rw,async,no_root_squash,no_subtree_check)' > /etc/exports
#           exportfs -arv
#           showmount -e
#           sudo /etc/init.d/nfs-kernel-server start
#         fi
#         bash /Users/acejilam/script/linux-install-bpf.sh
#         if [[ $(hostname) == "vm2404" ]]; then
#           # bash /Users/acejilam/script/linux-install-rust.sh
#           # bash /Users/acejilam/script/linux-install-k8s.sh
#           echo "over"
#         fi
      SHELL
      # 确保 vbguest
      vm.vm.provision "shell",run: "always", inline: <<-SHELL
        apt-get install -y build-essential dkms linux-headers-$(uname -r)
      SHELL

    end
  end
end
