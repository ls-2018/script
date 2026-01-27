#!/usr/bin/env zsh
#rm -rf /Volumes/Tf/data/harbor/{tgz,cert,logs}
set -v
# rm -rf /Volumes/Tf/data/harbor
# rm -rf /Volumes/Tf/data/harbor/{tgz,cert,logs}
mkdir -p /Volumes/Tf/data/harbor/{tgz,cert,data,logs}

export version=v2.12.2
cp /Volumes/Tf/resources/tar/arm64/harbor-offline-installer-aarch64-${version}.tgz /Volumes/Tf/data/harbor/tgz/

host_ip=$(ipconfig getifaddr en0)
if [ "$host_ip" = "" ]; then
	host_ip=$(ipconfig getifaddr en1)
fi
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

mv harbor.csr /Volumes/Tf/data/harbor/cert
mv harbor.key /Volumes/Tf/data/harbor/cert
mv harbor.crt /Volumes/Tf/data/harbor/cert

sudo security find-certificate -c 'ccr.ccs.tencentyun.com'
sudo security remove-trusted-cert -d /Volumes/Tf/data/harbor/cert/harbor.crt
sudo security delete-certificate -c 'ccr.ccs.tencentyun.com'
sudo security add-certificates /Volumes/Tf/data/harbor/cert/harbor.crt
sudo security add-trusted-cert -d /Volumes/Tf/data/harbor/cert/harbor.crt

rm -rf ~/.docker/certs.d/ccr.ccs.tencentyun.com
rm -rf ~/.docker/certs.d/harbor.ls.com

mkdir -p ~/.docker/certs.d/ccr.ccs.tencentyun.com
mkdir -p ~/.docker/certs.d/harbor.ls.com

cp -rf /Volumes/Tf/data/harbor/cert/harbor.crt ~/.docker/certs.d/ccr.ccs.tencentyun.com/
cp -rf /Volumes/Tf/data/harbor/cert/harbor.crt ~/.docker/certs.d/harbor.ls.com/

cd /Volumes/Tf/data/harbor/tgz
tar -zxvf harbor-offline-installer-aarch64-${version}.tgz

cp /Volumes/Tf/data/harbor/tgz/harbor/harbor.yml.tmpl /Volumes/Tf/data/harbor/tgz/harbor/harbor.yml

gsed -i 's@hostname: reg.mydomain.com@hostname: harbor.ls.com@g' /Volumes/Tf/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@data_volume: /data@data_volume: /Volumes/Tf/data/harbor/data@g' /Volumes/Tf/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@location: /var/log/harbor@location: /Volumes/Tf/data/harbor/logs@g' /Volumes/Tf/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@certificate: /your/certificate/path@certificate:  /Volumes/Tf/data/harbor/cert/harbor.crt@g' /Volumes/Tf/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@private_key: /your/private/key/path@private_key:  /Volumes/Tf/data/harbor/cert/harbor.key@g' /Volumes/Tf/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@${prepare_base_dir}@/Volumes/Tf/data/harbor@g' /Volumes/Tf/data/harbor/tgz/harbor/prepare

cd /Volumes/Tf/data/harbor/tgz/harbor && ./install.sh --with-trivy
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
	sleep 1
done

curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "acejilam", "public": true}'
curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "acejialm", "public": true}'
curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "ls-2018", "public": true}'
curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "ls-mock", "public": true}'

mkdir -p /Users/acejilam/.config/buildkit
cat >/Users/acejilam/.config/buildkit/buildkitd.toml <<EOF
[registry."harbor.ls.com"]
insecure = true
ca=["/Volumes/Tf/data/harbor/cert/harbor.crt"]
EOF

docker buildx inspect mygo | grep harbor.ls.com || {
	docker buildx rm mygo
	docker buildx create --name mygo --buildkitd-config /Users/acejilam/.config/buildkit/buildkitd.toml
}

# wget -O ~/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.darwin-arm64
