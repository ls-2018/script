echo 'gen_cert_v2.sh xxxx.com'
if [ $# -eq 0 ]; then
	exit 1
else
	ca_cn=$1
fi
# ca_cn=myself.com
# 生成.key  私钥文件
openssl genrsa -out ca.key 2048

# 生成.csr 证书签名请求文件
openssl req -new -key ca.key -out ca.csr -subj "/C=GB/L=China/O=lixd/CN=$ca_cn"

# 自签名生成.crt 证书文件
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=GB/L=China/O=lixd/CN=$ca_cn"

# server

# sudo find / -name "openssl.cnf"
cnf='/usr/local/etc/openssl@3/openssl.cnf'

cp $cnf /tmp/ssl.cnf
echo "\n[SAN]\nsubjectAltName=DNS:$ca_cn" >>/tmp/ssl.cnf
cat /tmp/ssl.cnf

# 生成.key  私钥文件
openssl genrsa -out server.key 2048

# 生成.csr 证书签名请求文件
openssl req -new -key server.key -out server.csr \
	-subj "/C=GB/L=China/O=lixd/CN=$ca_cn" \
	-reqexts SAN \
	-config /tmp/ssl.cnf

# 签名生成.crt 证书文件
openssl x509 -req -days 3650 \
	-in server.csr -out server.crt \
	-CA ca.crt -CAkey ca.key -CAcreateserial \
	-extensions SAN \
	-extfile /tmp/ssl.cnf

# client
# 生成.key  私钥文件
openssl genrsa -out client.key 2048

# 生成.csr 证书签名请求文件
openssl req -new -key client.key -out client.csr \
	-subj "/C=GB/L=China/O=lixd/CN=$ca_cn" \
	-reqexts SAN \
	-config /tmp/ssl.cnf

# 签名生成.crt 证书文件
openssl x509 -req -days 3650 \
	-in client.csr -out client.crt \
	-CA ca.crt -CAkey ca.key -CAcreateserial \
	-extensions SAN \
	-extfile /tmp/ssl.cnf

rm /tmp/ssl.cnf
