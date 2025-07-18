yum install epel-release yum-plugin-priorities wget -y
curl -o /etc/yum.repos.d/powerdns-auth-44.repo https://repo.powerdns.com/repo-files/centos-auth-44.repo
yum install pdns -y
yum install pdns-backend* -y --skip-broken

cp /resources/PowerDNS/schema.mysql.sql .
# 安装pdns
yum -y install mariadb mariadb-server
systemctl enable mariadb
systemctl start mariadb
# 创建数据库pdns，
$()
cat <<\EOF >/tmp/tmp.sql
create database pdns;
grant all privileges on pdns.* to 'admin'@'localhost' identified by 'Abcd1234';
EOF
mysql </tmp/tmp.sql
mysql -Dpdns <schema.mysql.sql

cat <<\EOF >>/etc/pdns/pdns.conf

#################################
# launch        Which backends to launch and order to query them in
launch=gmysql
gmysql-host=127.0.0.1
gmysql-user=admin
gmysql-password=Abcd1234
gmysql-dbname=pdns
EOF
systemctl enable pdns
chmod 777 /etc/pdns/pdns.conf
systemctl start pdns

# 测试
cat <<\EOF >/tmp/tmp.sql
INSERT INTO domains (name, type) values ('example.com', 'NATIVE');
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'example.com','localhost admin.example.com 1 10380 3600 604800 3600','SOA',86400,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'example.com','dns-us1.powerdns.net','NS',86400,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'example.com','dns-eu1.powerdns.net','NS',86400,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'www.example.com','192.0.2.10','A',120,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'mail.example.com','192.0.2.12','A',120,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'localhost.example.com','127.0.0.1','A',120,NULL);
INSERT INTO records (domain_id, name, content, type,ttl,prio)
VALUES (1,'example.com','mail.example.com','MX',120,25);
EOF
mysql -Dpdns </tmp/tmp.sql
yum -y install bind-utils
dig mail.example.com @127.0.0.1
