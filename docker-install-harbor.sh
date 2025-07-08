#!/usr/bin/env zsh
#rm -rf /Users/acejilam/data/harbor/{tgz,cert,logs}

# rm -rf /Users/acejilam/data/harbor
# rm -rf /Users/acejilam/data/harbor/{tgz,cert,logs}
mkdir -p /Users/acejilam/data/harbor/{tgz,cert,data,logs}

export version=v2.12.2
cp /Users/acejilam/resources/tar/arm64/harbor-offline-installer-aarch64-${version}.tgz /Users/acejilam/data/harbor/tgz/

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
CN = registry.cn-hangzhou.aliyuncs.com

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = registry.cn-hangzhou.aliyuncs.com
DNS.2 = harbor.ls.com
EOF

openssl req -new -sha256 -nodes -out harbor.csr -newkey rsa:2048 -keyout harbor.key -config /tmp/openssl.cnf
openssl x509 -req -in harbor.csr -signkey harbor.key -out harbor.crt -days 365 -extfile /tmp/openssl.cnf -extensions req_ext

mv harbor.csr /Users/acejilam/data/harbor/cert
mv harbor.key /Users/acejilam/data/harbor/cert
mv harbor.crt /Users/acejilam/data/harbor/cert

sudo security find-certificate -c 'registry.cn-hangzhou.aliyuncs.com'
sudo security remove-trusted-cert -d /Users/acejilam/data/harbor/cert/harbor.crt
sudo security delete-certificate -c 'registry.cn-hangzhou.aliyuncs.com'
sudo security add-certificates /Users/acejilam/data/harbor/cert/harbor.crt
sudo security add-trusted-cert -d /Users/acejilam/data/harbor/cert/harbor.crt

rm -rf ~/.docker/certs.d/registry.cn-hangzhou.aliyuncs.com
rm -rf ~/.docker/certs.d/harbor.ls.com

mkdir -p ~/.docker/certs.d/registry.cn-hangzhou.aliyuncs.com
mkdir -p ~/.docker/certs.d/harbor.ls.com

cp -rf /Users/acejilam/data/harbor/cert/harbor.crt ~/.docker/certs.d/registry.cn-hangzhou.aliyuncs.com/
cp -rf /Users/acejilam/data/harbor/cert/harbor.crt ~/.docker/certs.d/harbor.ls.com/

cd /Users/acejilam/data/harbor/tgz
tar -zxvf harbor-offline-installer-aarch64-${version}.tgz

cp /Users/acejilam/data/harbor/tgz/harbor/harbor.yml.tmpl /Users/acejilam/data/harbor/tgz/harbor/harbor.yml

gsed -i 's@hostname: reg.mydomain.com@hostname: harbor.ls.com@g' /Users/acejilam/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@data_volume: /data@data_volume: /Users/acejilam/data/harbor/data@g' /Users/acejilam/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@location: /var/log/harbor@location: /Users/acejilam/data/harbor/logs@g' /Users/acejilam/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@certificate: /your/certificate/path@certificate:  /Users/acejilam/data/harbor/cert/harbor.crt@g' /Users/acejilam/data/harbor/tgz/harbor/harbor.yml
gsed -i 's@private_key: /your/private/key/path@private_key:  /Users/acejilam/data/harbor/cert/harbor.key@g' /Users/acejilam/data/harbor/tgz/harbor/harbor.yml

cd /Users/acejilam/data/harbor/tgz/harbor && ./install.sh --with-trivy
cd -

# killall "Google Chrome"

# harbor.ls.com
# chrome://net-internals/#hsts;
# open -a "/Applications/Google Chrome.app" "https://harbor.ls.com"
open -a "/Applications/Safari.app" "https://harbor.ls.com"

sleep 5

docker login -u admin harbor.ls.com -p Harbor12345

curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "acejilam", "public": true}'
curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "ls-2018", "public": true}'
curl -k -u "admin:Harbor12345" -X POST -H "Content-Type: application/json" "https://harbor.ls.com/api/v2.0/projects/" -d '{"project_name": "ls-mock", "public": true}'

cat >/Users/acejilam/.config/buildkit/buildkitd.toml <<EOF
[registry."harbor.ls.com"]
insecure = true
ca=["/Users/acejilam/data/harbor/cert/harbor.crt"]
EOF

docker buildx rm mygo || true
docker buildx create --name mygo --buildkitd-config /Users/acejilam/.config/buildkit/buildkitd.toml

# wget -O ~/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.darwin-arm64
