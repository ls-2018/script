dataDir="/Users/acejilam/Documents/wechat"

# dataDir="/Volumes/Tf/data/wechat"

dataPath=$dataDir/wechat-mysql
exporterPath=$dataDir/wechat-article-exporter

mkdir -p $dataPath
mkdir -p $exporterPath

docker rm wechat-article-exporter -f
docker rm wechat-mysql -f

cat >$dataPath/my.cnf <<EOF
[mysqld]
host-cache-size=0
skip-name-resolve
datadir=/etc/mysql/data/
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
lower_case_table_names=1
user=mysql
pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock
!includedir /etc/mysql/conf.d/
EOF

docker run \
	-d \
	-p 13306:3306 \
	--name wechat-mysql \
	--restart=always \
	-e MYSQL_ROOT_PASSWORD=sk3RCBqtWxF2Tg4pawUv \
	-e MYSQL_LOG_BIN=OFF \
	-v $dataPath/my.cnf:/etc/my.cnf \
	-v $dataPath/data:/etc/mysql/data/ \
	-v $dataPath/conf:/etc/mysql/mysql.conf.d/ \
	registry.cn-hangzhou.aliyuncs.com/acejilam/mysql:8

docker pull registry.cn-hangzhou.aliyuncs.com/ls-2018/wechat-article-exporter

docker run --name wechat-article-exporter \
	-d \
	-e MYSQL_HOST=$(python3 -c'from print_proxy import *;print(get_ip())') \
	-e MYSQL_PORT=13306 \
	-e MYSQL_LOG_BIN=OFF \
	-e MYSQL_USER=root \
	-e MYSQL_PASSWORD=sk3RCBqtWxF2Tg4pawUv \
	-e MYSQL_DATABASE=wechat_article_exporter \
	-p 13000:3000 \
	-v $exporterPath:/app/.data \
	registry.cn-hangzhou.aliyuncs.com/ls-2018/wechat-article-exporter

sleep 2
open -a "/Applications/Google Chrome.app" "http://localhost:13000"
