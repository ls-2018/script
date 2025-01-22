#!/usr/bin/env zsh
mkdir -p ~/.ssh

set -x

cat /host_ssh/id_ed25519.pub >~/.ssh/authorized_keys
sudo sed -i 's/^#* *\\(PermitRootLogin\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#* *\\(PasswordAuthentication\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
ufw disable
systemctl restart sshd.service
echo -e "root\nroot" | (passwd root)
touch ~/.hushlogin

echo 'nameserver 114.114.114.114' >/etc/resolv.conf

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

apt install bash-completion -y

mkdir -p ~/.gopath/bin
test -e ~/.gopath/bin/kubectl || {
    curl -LO "https://files.m.daocloud.io/dl.k8s.io/release/$(curl -L -s https://files.m.daocloud.io/dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl"
    chmod +x kubectl
    mv kubectl ~/.gopath/bin/kubectl
}
