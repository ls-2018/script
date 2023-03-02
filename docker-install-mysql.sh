set -e
docker rm mysql --force
cd ~
homePath=$(pwd)
dataPath="$homePath/data/mysql"
cd -

# docker cp mysql:/etc/mysql/mysql.conf.d/mysqld.cnf  .
docker run -p 3306:3306 --name mysql --restart=always -e MYSQL_ROOT_PASSWORD=root -v $dataPath/data:/etc/mysql/data/ -v $dataPath/conf:/etc/mysql/mysql.conf.d/ -d mysql
