#!/usr/bin/env bash
# 启动前就写好 udev 和 netplan
fix_ip=${1-}
mac=${2-}
set -x
# 用 awk
get_ip_prefix_awk() {
	echo "$1" | awk -F '.' '{print $1"."$2"."$3}'
}

sudo mkdir -p /etc/systemd/network
cat <<EOF | sudo tee /etc/systemd/network/10-eth100.link
[Match]
MACAddress=${mac}
[Link]
Name=eth100
EOF

sudo mkdir -p /etc/netplan
cat <<EOF | sudo tee /etc/netplan/100-eth100.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth100:
      dhcp4: no
      addresses: [${fix_ip}/24]
EOF

chmod 644 /etc/netplan/100-eth100.yaml

sudo netplan apply

sleep 2

ip a

ip route
