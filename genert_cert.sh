#!/bin/zsh
DOMAIN_NAME="flask-sidecar-injector.default.svc"

openssl rand -writerand ~/.rnd

old_func() {
	# --------------------------------------------------ca-------------------------------------------------------
	openssl genrsa -out ca.key 2048
	openssl req -new -x509 -key ca.key -out ca.crt -subj /C=CN/ST=Beijing/L=Beijing/O=CA
	# --------------------------------------------------客户端-------------------------------------------------------

	# 1、生成RSA密钥
	openssl genrsa -out flask.key 2048
	# 2、生成证书请求
	openssl req -new -sha256 -key flask.key -out flask.csr -subj /C=CN/ST=Beijing/L=Beijing/O=Devops/CN=myself.com
	# 这里将生成一个新的文件flask.csr，即一个证书请求文件，你可以拿着这个文件去数字证书颁发机构（即CA）申请一个数字证书。CA会给你一个新的文件flask.csr，那才是你的数字证书。
	# 2.1 使用CA对证书进行签名
	# openssl x509 -req -in flask.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out flask.crt -days 36500

	#2、制作自签证书# -------可以使用域名访问myself.com--------------
	# 如果是自己做测试，那么证书的申请机构和颁发机构都是自己。就可以用下面这个命令来生成证书：
	openssl req -new -x509 -key flask.key -out flask.crt -subj /C=CN/ST=Beijing/L=Beijing/O=Devops/CN=myself.com -days 360000

	# 3 查看证书信息
	openssl x509 -in flask.crt -text -noout
	# key 私钥
	# csr 签名申请
	# crt  证书
}

# 私钥 (可以用来解密、签名)
# 公开的：公钥 证书(用私钥签名,经过CA认证的公钥;可以用来加密、验签)
# 客户端拿着证书加密，服务端拿着私钥解密
# 服务端会在建立连接后将证书发往客户端
# 要达到数据安全传输的目的，必须发送方和接收方都持有对方的公钥和自己私钥；
# 为保证自己所持有的的对方的公钥不被篡改，需要CA机构对其进行验证,即用ca的公钥解密证书;解密成功也就拿到了原始的公钥

strA=$(go version)
strB="darwin"
result=$(echo $strA | grep "${strB}")
if [[ "$result" != "" ]]; then
	export cnf_path='/System/Library/OpenSSL/openssl.cnf'
else
	export cnf_path='/etc/pki/tls/openssl.cnf'
fi

res=$(url=$(go version) && echo "print('${url:13:4}' >= '1.15')" | python3)

if [ $res = "True" ]; then
	openssl genrsa -out ca.key 2048
	openssl req -x509 -new -nodes -key ca.key -subj "/CN=example.ca.com" -days 5000 -out ca.crt

	openssl genrsa -out server.key 2048
	openssl req -new -sha256 -key server.key -subj "/C=CN/ST=Beijing/L=Beijing/O=UnitedStack/OU=Devops/CN=${DOMAIN_NAME}" \
		-reqexts SAN -config <(cat /System/Library/OpenSSL/openssl.cnf <(printf "[SAN]\nsubjectAltName=DNS:${DOMAIN_NAME}")) \
		-out server.csr
	openssl x509 -req -days 365000 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
		-extfile <(printf "subjectAltName=DNS:${DOMAIN_NAME}") -out server.crt
else
	openssl req -newkey rsa:2048 -nodes -keyout server.key -x509 -out server.crt -subj /C=CN/ST=Beijing/L=Beijing/O=Devops/CN=${DOMAIN_NAME} -days 365000
fi
