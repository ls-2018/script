#!/usr/bin/env zsh
set -x
touch ~/.hushlogin # 关闭登录提示

rm -rf /etc/apt/sources.list.d/gierens.list
sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@http://.*ports.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*ports.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@deb https://mirrors.bfsu.edu.cn@# deb https://mirrors.bfsu.edu.cn@g" /etc/apt/sources.list
sed -i "s@deb https://mirrors.bfsu.edu.cn@# deb https://mirrors.bfsu.edu.cn@g" /etc/apt/sources.list.d/*

localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

apt-get update && echo "🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥"

apt install curl git make cmake htop bridge-utils net-tools -y

systemctl stop unattended-upgrades.service
systemctl disable unattended-upgrades.service
