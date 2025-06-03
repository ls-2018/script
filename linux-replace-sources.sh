#!/usr/bin/env bash
set -x
touch ~/.hushlogin # 关闭登录提示
onlyUpdate=$1
rm -rf /etc/apt/sources.list.d/gierens.list
sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@http://.*ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@deb https://mirrors.bfsu.edu.cn@# deb http://mirrors.bfsu.edu.cn@g" /etc/apt/sources.list
sed -i "s@deb https://mirrors.bfsu.edu.cn@# deb http://mirrors.bfsu.edu.cn@g" /etc/apt/sources.list.d/*

# sed -i 's@deb.debian.org@mirrors.aliyun.com@g' /etc/apt/sources.list.d/debian.sources
sed -i 's@deb.debian.org@mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list.d/debian.sources

localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

apt-get update && echo "🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥"
if [[ $onlyUpdate == "update" ]]; then
	apt install apt-transport-https ca-certificates -y
	apt install curl git make cmake htop bridge-utils net-tools inetutils-ping -y

	systemctl stop unattended-upgrades.service
	systemctl disable unattended-upgrades.service
fi
echo "success"
