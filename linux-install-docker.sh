#!/usr/bin/env bash

apt install docker.io -y

mkdir -p /etc/systemd/system/docker.service.d

cat >/etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://hproxy.it.zetyun.cn:1080"
Environment="HTTPS_PROXY=http://hproxy.it.zetyun.cn:1080"
Environment="NO_PROXY=localhost,127.0.0.1,::1"
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl restart docker

systemctl show --property=Environment docker

git clone -b equuleus --single-branch https://github.com/vyos/vyos-build
cd vyos-build

docker run --rm -it --privileged \
	-e http_proxy=http://10.230.205.24:7890 \
	-e https_proxy=http://10.230.205.24:7890 \
	-e all_proxy=socks5://10.230.205.24:7890 \
	-v $(pwd):/vyos -w /vyos \
	vyos/vyos-build:equuleus bash

docker run --rm -it --privileged \
	-e http_proxy=http://hproxy.it.zetyun.cn:1080 \
	-e https_proxy=http://hproxy.it.zetyun.cn:1080 \
	-e all_proxy=socks5://hproxy.it.zetyun.cn:1080 \
	-v $(pwd):/vyos -w /vyos \
	vyos/vyos-build:equuleus bash

sed -i 's/archive.debian.org/mirrors.tuna.tsinghua.edu.cn/g' build/build-config.json
sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' build/build-config.json

./configure --architecture amd64 --build-by "your‑identifier" --build-type release --version "1.3‑epa2"
sudo make iso
