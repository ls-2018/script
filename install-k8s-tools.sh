set -x
GO111MODULE="on" go install sigs.k8s.io/kind@latest

brew install helm

version="v3.9.1"
os=$(go env GOOS)     #替换下面命令的darwin
arch=$(go env GOARCH) #替换下面命令的amd64
rm ~/.gopath/bin/kubebuilder
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && sudo mv kubebuilder ~/.gopath/bin/kubebuilder

# #下载安装包 如果需要指定版本 使用版本号替换 $(curl -L -s https://files.m.daocloud.io/dl.k8s.io/release/stable.txt) 即可
# curl -LO "https://files.m.daocloud.io/dl.k8s.io/release/$(curl -L -s https://files.m.daocloud.io/dl.k8s.io/release/stable.txt)/bin/$(uname |tr '[:upper:]' '[:lower:]')/amd64/kubectl"
# #验证可执行文件
# #下载校验和
# curl -LO "https://files.m.daocloud.io/dl.k8s.io/$(curl -L -s https://files.m.daocloud.io/dl.k8s.io/release/stable.txt)/bin/$(uname |tr '[:upper:]' '[:lower:]')/amd64/kubectl.sha256"
# #验证
# echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
# # 输出 kubectl: OK 则验证通过
# # 未通过重新下载即可

# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# # 执行不通过可以手动给权限
# sudo chmod +x kubectl && mv kubectl /usr/local/bin/kubectl
# # 查看版本
# kubectl version --client
# #yaml格式输出
# kubectl version --client --output=yaml

# #检查是否安装bash-completion
# type _init_completion
# #安装bash-completion
# yum install bash-completion -y

# #编辑 ~/.bashrc 或者 /etc/bashrc 文件 加入下面代码
# # 内容
# echo '[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion' >>/etc/bashrc

# # 刷新配置
# source /etc/bashrc # or source /etc/bashrc
# #检查是否安装成功
# type _init_completion
# #启用kubectl自动补全
# #只给当前用户设置
# echo 'source <(kubectl completion bash)' >>~/.bashrc
# #系统全局设置
# kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl >/dev/null
