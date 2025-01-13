#!/usr/bin/env zsh

mkdir -p ~/.ssh

cat /host_ssh/id_ed25519.pub >~/.ssh/authorized_keys
sudo sed -i 's/^#* *\\(PermitRootLogin\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#* *\\(PasswordAuthentication\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
ufw disable
systemctl restart sshd.service
echo -e "root\nroot" | (passwd root)
touch ~/.hushlogin
mkdir -p ~/.gopath/bin

echo 'nameserver 114.114.114.114' >/etc/resolv.conf

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

curl -L ${GITHUB_PROXY}/https://raw.githubusercontent.com/ls-2018/script/refs/heads/master/linux-replace-sources.sh | bash

apt install bash-completion -y
source /etc/profile

test -e ~/.gopath/bin/kubectl || {
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl"
    chmod +x kubectl
    mv kubectl ~/.gopath/bin/kubectl
}

git config --global url."${GITHUB_PROXY}/https://github.com".insteadOf https://github.com
