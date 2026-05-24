#!/usr/bin/env bash
set -ex
touch ~/.hushlogin # 关闭登录提示
onlyUpdate=$1
rm -rf /etc/apt/sources.list.d/gierens.list

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

# "阿里云@mirrors.aliyun.com"
# "腾讯云@mirrors.tencent.com"
# "华为云@mirrors.huaweicloud.com"
# "网易@mirrors.163.com"
# "火山引擎@mirrors.volces.com"
# "清华大学@mirrors.tuna.tsinghua.edu.cn"
# "北京大学@mirrors.pku.edu.cn"
# "浙江大学@mirrors.zju.edu.cn"
# "南京大学@mirrors.nju.edu.cn"
# "兰州大学@mirror.lzu.edu.cn"
# "上海交通大学@mirror.sjtu.edu.cn"
# "重庆邮电大学@mirrors.cqupt.edu.cn"
# "中国科学技术大学@mirrors.ustc.edu.cn"
# "中国科学院软件研究所@mirror.iscas.ac.cn"

curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh | bash -s -- \
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

# 禁止内核自动升级
apt-mark hold linux-image-generic linux-headers-generic
systemctl stop unattended-upgrades || true
systemctl disable unattended-upgrades || true
