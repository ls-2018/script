#!/usr/bin/env zsh
<<<<<<< HEAD
#rm -rf /Volumes/Tf/data/harbor/{tgz,cert,logs}
<<<<<<< HEAD
set -vx
rm -rf /Volumes/Tf/data/harbor/{data,cert,logs}
=======
set -x
rm -rf /Volumes/Tf/data/harbor
# rm -rf /Volumes/Tf/data/harbor/{tgz,cert,logs}
>>>>>>> 26f3561 (-)
mkdir -p /Volumes/Tf/data/harbor/{tgz,cert,data,logs}
=======

base_dir="/Volumes/Tf/data/harbor"

set -x

rm -rf ${base_dir}
# rm -rf ${base_dir}/{tgz,cert,logs}
mkdir -p ${base_dir}/{tgz,cert,data,logs}
>>>>>>> 34ebed8 (-)

export version=v2.12.2
src_file="/Volumes/Tf/resources/tar/arm64/harbor-offline-installer-aarch64-${version}.tgz"
dst_file="${base_dir}/tgz/harbor-offline-installer-aarch64-${version}.tgz"
if [ -f "$dst_file" ]; then
    src_md5=$(md5 -q "$src_file")
    dst_md5=$(md5 -q "$dst_file")
    if [ "$src_md5" = "$dst_md5" ]; then
        echo "MD5相同，跳过复制"
    else
        cp "$src_file" "$dst_file"
    fi
else
    cp "$src_file" "$dst_file"
fi
<<<<<<< HEAD
=======

>>>>>>> 26f3561 (-)

host_ip=$(python3 -c'from print_proxy import *;print(get_ip())')
echo $host_ip
if [ "$host_ip" = "" ]; then
	echo "获取不到本机IP，请检查网络"
	exit 1
fi

cat >/tmp/openssl.cnf <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
C = CN
ST = State
L = Locality
O = Organization
OU = Organizational Unit
CN = ccr.ccs.tencentyun.com

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ccr.ccs.tencentyun.com
DNS.2 = harbor.ls.com
IP.1  = $host_ip
EOF

openssl req -new -sha256 -nodes -out harbor.csr -newkey rsa:2048 -keyout harbor.key -config /tmp/openssl.cnf
openssl x509 -req -in harbor.csr -signkey harbor.key -out harbor.crt -days 365 -extfile /tmp/openssl.cnf -extensions req_ext

mv harbor.csr ${base_dir}/cert
mv harbor.key ${base_dir}/cert
mv harbor.crt ${base_dir}/cert

sudo security find-certificate -c 'ccr.ccs.tencentyun.com'
sudo security remove-trusted-cert -d ${base_dir}/cert/harbor.crt
sudo security delete-certificate -c 'ccr.ccs.tencentyun.com'
sudo security add-certificates ${base_dir}/cert/harbor.crt
sudo security add-trusted-cert -d ${base_dir}/cert/harbor.crt

rm -rf ~/.docker/certs.d/ccr.ccs.tencentyun.com
rm -rf ~/.docker/certs.d/harbor.ls.com

mkdir -p ~/.docker/certs.d/ccr.ccs.tencentyun.com
mkdir -p ~/.docker/certs.d/harbor.ls.com

cp -rf ${base_dir}/cert/harbor.crt ~/.docker/certs.d/ccr.ccs.tencentyun.com/
cp -rf ${base_dir}/cert/harbor.crt ~/.docker/certs.d/harbor.ls.com/
# 重启一下 docker, 或者将 harbor.ls.com 加入到 Docker 的不安全仓库列表中

cd ${base_dir}/tgz
tar -zxvf harbor-offline-installer-aarch64-${version}.tgz

cp ${base_dir}/tgz/harbor/harbor.yml.tmpl ${base_dir}/tgz/harbor/harbor.yml

gsed -i "s@hostname: reg.mydomain.com@hostname: harbor.ls.com@g" ${base_dir}/tgz/harbor/harbor.yml
gsed -i "s@data_volume: /data@data_volume: ${base_dir}/data@g" ${base_dir}/tgz/harbor/harbor.yml
gsed -i "s@location: /var/log/harbor@location: ${base_dir}/logs@g" ${base_dir}/tgz/harbor/harbor.yml
gsed -i "s@certificate: /your/certificate/path@certificate:  ${base_dir}/cert/harbor.crt@g" ${base_dir}/tgz/harbor/harbor.yml
gsed -i "s@private_key: /your/private/key/path@private_key:  ${base_dir}/cert/harbor.key@g" ${base_dir}/tgz/harbor/harbor.yml
gsed -i "s@\${prepare_base_dir}@${base_dir}@g" ${base_dir}/tgz/harbor/prepare

cd ${base_dir}/tgz/harbor && ./install.sh --with-trivy
docker-compose down
docker-compose down
docker-compose up -d
cd -

# killall "Google Chrome"

# harbor.ls.com
# chrome://net-internals/#hsts;
# open -a "/Applications/Google Chrome.app" "https://harbor.ls.com"
open -a "/Applications/Safari.app" "https://harbor.ls.com"

while true; do
	docker login -u admin harbor.ls.com -p Harbor12345
	if [ $? -eq 0 ]; then
		echo "Login successful!"
		break
	fi
	echo "Login failed, retrying..."
	sleep 3
done

curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "acejilam", "public": true}'
curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "ls-2018", "public": true}'
curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "ls-mock", "public": true}'

mkdir -p /Users/acejilam/.config/buildkit
cat >/Users/acejilam/.config/buildkit/buildkitd.toml <<EOF
[registry."harbor.ls.com"]
insecure = true
ca=["${base_dir}/cert/harbor.crt"]
EOF

docker buildx inspect mygo | grep harbor.ls.com || {
	docker buildx rm mygo
	docker buildx create --name mygo --buildkitd-config /Users/acejilam/.config/buildkit/buildkitd.toml
}

# wget -O ~/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.darwin-arm64
