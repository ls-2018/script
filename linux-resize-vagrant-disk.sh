#!/usr/bin/env bash
set -x
echo "查看当前的 LVM 配置..."
sudo vgdisplay
sudo lvdisplay

export DEVPATH=$(lvdisplay | grep 'LV Path' | awk -F ' ' '{print $3}')

echo "扩展逻辑卷 (将分配所有剩余空间)..."
sudo lvextend -r -l +100%FREE ${DEVPATH}
sudo resize2fs ${DEVPATH}

echo "完成！新的根分区大小: "
df -h /
