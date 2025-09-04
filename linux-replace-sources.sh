#!/usr/bin/env bash
set -v
touch ~/.hushlogin # 关闭登录提示
onlyUpdate=$1
rm -rf /etc/apt/sources.list.d/gierens.list

curl -sSL https://linuxmirrors.cn/main.sh | bash -s -- \
	--source mirrors.aliyun.com \
	--protocol https \
	--use-intranet-source false \
	--install-epel true \
	--backup true \
	--upgrade-software false \
	--clean-cache false \
	--ignore-backup-tips

if command -v apt-get &>/dev/null; then
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
	apt-get update && echo "🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥"
	if [[ $onlyUpdate == "update" ]]; then
		apt install apt-transport-https ca-certificates -y
		apt install curl git make cmake htop bridge-utils net-tools inetutils-ping -y

		systemctl stop unattended-upgrades.service
		systemctl disable unattended-upgrades.service
	fi
fi

echo "success"

cat >/etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=114.114.114.114
EOF

if command -v systemctl &>/dev/null; then
	systemctl restart systemd-resolved
fi
if command -v resolvectl &>/dev/null; then
	resolvectl status
fi
