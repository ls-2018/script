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
    export version=$(curl -L -s https://gitee.com/ls-2018/kubectl/raw/master/stable.txt)
    echo $version
    curl -o ~/.gopath/bin/kubectl https://gitee.com/ls-2018/kubectl/raw/master/${version}/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl
    chmod +x ~/.gopath/bin/kubectl
}
