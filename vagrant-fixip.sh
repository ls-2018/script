#!/usr/bin/env bash
fix_ip=${1-}

# 获取 eth0 的 MAC 地址
MAC=$(cat /sys/class/net/eth1/address)

# 创建 udev 规则永久改名
RULE_FILE="/etc/udev/rules.d/70-persistent-net.rules"
echo "SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$MAC\", NAME=\"eth100\"" | sudo tee $RULE_FILE

# 临时改名当前会话生效
sudo ip link set dev eth1 name eth100

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
sudo netplan apply

sleep 2
ip a
ip route
