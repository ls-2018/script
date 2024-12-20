#!/usr/bin/env zsh
rm -rf /etc/apt/sources.list.d/gierens.list
sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@http://.*ports.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*ports.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*

sed -i "s@deb https://mirrors.bfsu.edu.cn@# deb https://mirrors.bfsu.edu.cn@g" /etc/apt/sources.list
sed -i "s@deb https://mirrors.bfsu.edu.cn@# deb https://mirrors.bfsu.edu.cn@g" /etc/apt/sources.list.d/*

apt-get update && echo "🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥🐥"
