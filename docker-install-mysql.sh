set -e
docker rm mysql --force
cd ~

dataPath="/Volumes/Tf/data/mysql"

mkdir -p $dataPath
cd -
cat >$dataPath/my.cnf <<EOF
[mysqld]
host-cache-size=0
skip-name-resolve
datadir=/etc/mysql/data/
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql
pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock
!includedir /etc/mysql/conf.d/
EOF

# docker cp mysql:/etc/mysql/mysql.conf.d/mysqld.cnf  .
docker run \
	-d \
	-p 3306:3306 \
	--name mysql \
	--restart=always \
	-e MYSQL_ROOT_PASSWORD=sk3RCBqtWxF2Tg4pawUv \
	-e MYSQL_LOG_BIN=OFF \
	-v $dataPath/my.cnf:/etc/my.cnf \
	-v $dataPath/data:/etc/mysql/data/ \
	-v $dataPath/conf:/etc/mysql/mysql.conf.d/ \
	registry.cn-hangzhou.aliyuncs.com/acejilam/mysql:8
