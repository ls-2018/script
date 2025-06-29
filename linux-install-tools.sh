#!/usr/bin/env bash
mkdir -p ~/.ssh

set -x

cat /host_ssh/id_ed25519.pub >>~/.ssh/authorized_keys
ls /resources/ssh | grep pub | xargs -I {} cat /resources/ssh/{} | tee -a ~/.ssh/authorized_keys
cp /resources/ssh/$(hostname)* ~/.ssh

mv ~/.ssh/$(hostname) ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
mv ~/.ssh/$(hostname).pub ~/.ssh/id_ed25519.pub

sed -i "s/#UseDNS yes/UseDNS no/g" /etc/ssh/sshd_config
# sudo sed -i 's/^#* *\\(PermitRootLogin\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
# sudo sed -i 's/^#* *\\(PasswordAuthentication\\)\\(.*\\)$/\\1 yes/' /etc/ssh/sshd_config
sed -i 's/^#* *\(PermitRootLogin\)\(.*\)$/\1 yes/' /etc/ssh/sshd_config
sed -i 's/^#* *\(PasswordAuthentication\)\(.*\)$/\1 yes/' /etc/ssh/sshd_config
# 跳过 yes 选择
sed -i 's/^#* *\(StrictHostKeyChecking\)\(.*\)$/\1 no/' /etc/ssh/ssh_config

ufw disable
systemctl restart ssh
echo -e "root\nroot" | (passwd root)
touch ~/.hushlogin

echo 'nameserver 114.114.114.114' >/etc/resolv.conf
resolvectl dns eth0 114.114.114.114
resolvectl dns eth1 114.114.114.114

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

apt install bash-completion -y

# git clone https://gitee.com/ls-2018/resources.git
mkdir -p ~/.gopath/bin

rm -rf ~/.gopath/bin/kubectl
cp /resources/k8s/${ARCH}/kubectl ~/.gopath/bin/kubectl
chmod +x ~/.gopath/bin/kubectl

timedatectl set-timezone "Asia/Shanghai"
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo 'server ntp1.aliyun.com' >/etc/ntp.conf
apt install ntpdate -y
ntpdate -u ntp1.aliyun.com
timedatectl
touch /tmp/crontab.bak
crontab /tmp/crontab.bak
# crontab -l >/tmp/crontab.bak
echo "*/1 * * * * /usr/sbin/ntpdate -u ntp1.aliyun.com | logger -t NTP" >>/tmp/crontab.bak
crontab /tmp/crontab.bak

apt install musl-tools git curl -y
