#! /usr/bin/env zsh
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
source "$SCRIPT_DIR/.alias.sh"

dataDir="/Users/acejilam/Documents/wechat"

# dataDir="/Volumes/Tf/data/wechat"

dataPath=$dataDir/wechat-mysql
exporterPath=$dataDir/wechat-article-exporter

mkdir -p $dataPath
mkdir -p $exporterPath

docker rm wechat-article-exporter -f
docker rm wechat-mysql -f
docker network rm wechat
docker network create wechat

cat >$dataPath/my.cnf <<EOF
[mysqld]
host-cache-size=0
skip-name-resolve
binlog_expire_logs_seconds = 10
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
	--label com.docker.compose.project=wechat \
	--network wechat \
	--restart=always \
	-e MYSQL_ROOT_PASSWORD=sk3RCBqtWxF2Tg4pawUv \
	-e MYSQL_LOG_BIN=OFF \
	-v $dataPath/my.cnf:/etc/my.cnf \
	-v $dataPath/data:/etc/mysql/data/ \
	-v $dataPath/conf:/etc/mysql/mysql.conf.d/ \
	$(trans-image-name docker.io/library/mysql:8)

docker pull ccr.ccs.tencentyun.com/ls-2018/wechat-article-exporter

docker run \
	--name wechat-article-exporter \
	--restart=always \
	--label com.docker.compose.project=wechat \
	--network wechat \
	-d \
	-e MYSQL_HOST=$(python3 -c'from print_proxy import *;print(get_ip())') \
	-e MYSQL_PORT=13306 \
	-e MYSQL_LOG_BIN=OFF \
	-e MYSQL_USER=root \
	-e MYSQL_PASSWORD=sk3RCBqtWxF2Tg4pawUv \
	-e MYSQL_DATABASE=wechat_article_exporter \
	-p 13000:3000 \
	-v $exporterPath:/app/.data \
	ccr.ccs.tencentyun.com/ls-2018/wechat-article-exporter

pkill -9 'Chromium'
sleep 2
open -a "/Applications/Chromium.app" "http://localhost:13000"

cat /tmp/wechat.log | awk -F ' ' '{print $10}' | grep '\.' | grep -v '\.\.' | sort -nr | uniq -c

# SHOW BINARY LOGS;
# PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 1 MINUTE);
