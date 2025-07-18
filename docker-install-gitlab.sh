set -e
docker rm gitlab --force
cd ~
homePath=$(pwd)
dataPath="$homePath/data/gitlab"
cd -

docker run -d -p 443:443 -p 80:80 -p 222:22 --name gitlab --restart always \
	-v $dataPath/etc:/etc/gitlab \
	-v $dataPath/logs:/var/log/gitlab \
	-v $dataPath/data:/var/opt/gitlab \
	gitlab/gitlab-ce
