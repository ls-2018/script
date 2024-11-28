# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.hostname = "ebpf"
  config.vm.box_check_update = false
  config.vm.network "private_network",ip: "192.168.33.10",hostname: true
  config.vm.synced_folder "~/.ssh", "/host_ssh", mount_options:["dmode=775","fmode=664"]
  config.vm.provider "virtualbox" do |vb|
    vb.name = "ebpf"
    vb.gui = false
    vb.cpus = "4"
    vb.memory = "4096"
  end

  config.vm.provision "shell", inline: <<-SHELL
    cat /host_ssh/id_ed25519.pub > ~/.ssh/authorized_keys
    sudo sed -i 's/^#* *\\(PermitRootLogin\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
    sudo sed -i 's/^#* *\\(PasswordAuthentication\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
    ufw disable
    systemctl restart sshd.service
    echo -e "vagrant\nvagrant" | (passwd vagrant)
    echo -e "root\nroot" | (passwd root)
    touch ~/.hushlogin

    echo 'nameserver 114.114.114.114' > /etc/resolv.conf

    curl -L https://files.m.daocloud.io/raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-replace-sources.sh | bash
    curl -L https://files.m.daocloud.io/raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-rust.sh | bash
    curl -L https://files.m.daocloud.io/raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-bpf.sh | bash
    curl -L https://files.m.daocloud.io/raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-install-go.sh | bash


  SHELL
end
