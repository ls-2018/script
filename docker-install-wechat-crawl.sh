#! /usr/bin/env zsh
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"
source "$SCRIPT_DIR/.alias.sh"

docker rm wechat-article-exporter -f >/dev/null 2>&1
docker rm wechat-mysql -f >/dev/null 2>&1
docker rm wechat-article-display -f >/dev/null 2>&1
docker network rm wechat >/dev/null 2>&1
docker network create wechat >/dev/null 2>&1

MYSQL_PASSWORD=$(docker run --rm alpine sh -c "cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32")

SqlBakDir="/Users/acejilam/script/data/wechat"
RunDir="/Users/acejilam/Documents/wechat"

# download this file to $SqlBakDir
# https://media.githubusercontent.com/media/ls-2018/script/refs/heads/main/data/wechat/wechat_article_exporter.sql
# https://media.githubusercontent.com/media/ls-2018/script/refs/heads/main/data/wechat/wechat_query.sql

dataPath=$RunDir/wechat-mysql
exporterPath=$RunDir/wechat-article-exporter

rm -rf $dataPath
mkdir -p $dataPath
mkdir -p $exporterPath

echo $MYSQL_PASSWORD
echo $MYSQL_PASSWORD >$RunDir/mysql.password.txt

set -x

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

\docker run \
	-d \
	-p 127.0.0.1:13306:3306 \
	--name wechat-mysql \
	--label com.docker.compose.project=wechat \
	--network wechat \
	--restart=always \
	-e MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD \
	-e MYSQL_LOG_BIN=OFF \
	-v $dataPath/my.cnf:/etc/my.cnf \
	-v $dataPath/data:/etc/mysql/data/ \
	-v $dataPath/conf:/etc/mysql/mysql.conf.d/ \
	$(trans-image-name docker.io/library/mysql:8)

sleep 5

\docker run \
	--name wechat-article-display \
	--restart=always \
	--label com.docker.compose.project=wechat \
	--network wechat \
	-d \
	-v $SqlBakDir:/data \
	-e BAK_DIR=$SqlBakDir \
	-e REMOTE_ADDR="172.18.0.1" \
	-e DB_PASSWORD=$MYSQL_PASSWORD \
	-e MYSQL_HOST=wechat-mysql \
	-e MYSQL_PORT=3306 \
	-e MYSQL_LOG_BIN=OFF \
	-e MYSQL_USER=root \
	-e MYSQL_PASSWORD=$MYSQL_PASSWORD \
	-e MYSQL_DATABASE=wechat_article_exporter \
	-p 127.0.0.1:13001:13001 \
	ccr.ccs.tencentyun.com/ls-2018/wechat:display

sleep 5

\docker run \
	--name wechat-article-exporter \
	--restart=always \
	--label com.docker.compose.project=wechat \
	--network wechat \
	-d \
	-e MYSQL_HOST=wechat-mysql \
	-e MYSQL_PORT=3306 \
	-e MYSQL_LOG_BIN=OFF \
	-e MYSQL_USER=root \
	-e MYSQL_PASSWORD=$MYSQL_PASSWORD \
	-e MYSQL_DATABASE=wechat_article_exporter \
	-p 127.0.0.1:13000:3000 \
	-v $exporterPath:/app/.data \
	ccr.ccs.tencentyun.com/ls-2018/wechat-article-exporter

set +x
pkill -9 'Chromium'
sleep 2
open -a "/Applications/Chromium.app" "http://localhost:13000"
open -a "/Applications/Chromium.app" "http://localhost:13001"

# SHOW BINARY LOGS;
# PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 1 MINUTE);
