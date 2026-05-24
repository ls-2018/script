#!/bin/zsh
docker rm jenkins --force
rm -rf /tmp/jenkins_home
mkdir /tmp/jenkins_home
docker run --name jenkins \
	-d \
	-p 18080:8080 \
	-p 50000:50000 \
	-v /tmp/jenkins_home:/var/jenkins_home \
	--restart always \
	jenkins/jenkins:lts

cat <<\EOF
usage:
    http://127.0.0.1:18080/
    docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
    default_path=$(find / -name "default.json" | grep default)
    sed -i 's/http:\/\/updates.jenkins-ci.org\/download/https:\/\/mirrors.tuna.tsinghua.edu.cn\/jenkins/g' ${default_path}
    sed -i 's/http:\/\/www.google.com/https:\/\/www.baidu.com/g' ${default_path}
    curl http://127.0.0.1:18080/restart
    系统管理>>管理插件>>高级
    将 [升级站点] 更换为
    https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/current/update-center.json
EOF
