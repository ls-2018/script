cat <<COMMENT >/dev/null
apt install openssh-server net-tools vim htop -y
sed -i 's@/root@/Users/acejilam@g' /etc/passwd

mkdir -p /Users/acejilam/script /Users/acejilam/resources /resources /host_ssh /Users/acejilam/.kube /Users/acejilam/.docker_images
chmod 700 /Users/acejilam
chown root:root /Users/acejilam
COMMENT

rsync -avzP --delete --delete /Users/acejilam/script/ root@pxe:/Users/acejilam/script/
rsync -avzP --delete --delete /Volumes/Tf/resources/ root@pxe:/resources/
rsync -avzP --delete --delete /Volumes/Tf/resources/ root@pxe:/Volumes/Tf/resources/

ssh root@pxe "bash -i /Users/acejilam/script/linux-replace-sources.sh"
ssh root@pxe "bash -i /Users/acejilam/script/linux-install-tools.sh"
ssh root@pxe "bash -i /Users/acejilam/script/linux-install-zsh.sh"
ssh root@pxe "bash -i /Users/acejilam/script/linux-install-go.sh"
ssh root@pxe "bash -i /Users/acejilam/script/.linux-add-env.sh"
ssh root@pxe "bash -i /Users/acejilam/script/linux-install-bpf.sh"
ssh root@pxe "bash -i /Users/acejilam/script/linux-install-rust.sh"

cat >/tmp/vagrant.sh <<EOF
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant -y
sudo apt install virtualbox -y
EOF

scp /tmp/vagrant.sh root@pxe:/tmp/vagrant.sh
ssh root@pxe "bash -i /tmp/vagrant.sh"
