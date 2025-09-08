#!/usr/bin/env bash
set -x
echo "查看当前的 LVM 配置..."

export DEVPATH=$(lvdisplay | grep 'LV Path' | awk -F ' ' '{print $3}')

sudo growpart /dev/sda 3
sudo pvresize /dev/sda3
sudo lvextend -l +100%FREE ${DEVPATH}
sudo resize2fs ${DEVPATH} # ext4
# 或者 sudo xfs_growfs / 如果是 XFS

echo "完成！新的根分区大小: "
df -h /

sudo partprobe /dev/sda
lsblk
