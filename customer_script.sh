#!/usr/bin/env bash

# setopt no_nomatch
export GOPATH=${HOME}/.gopath
export GOPATH=~/.gopath
export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk

mkdir -p $GOPATH/{bin,pkg,src}
mkdir -p ~/.cargo/{target,registry,git}
export RUSTC_WRAPPER=sccache

# Mac
# CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build main.go
# windows
# CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
# Linux
# CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build main.go

# https://zhuanlan.zhihu.com/p/383707713
SOFTWARE_HOME=~/software
export HELM_CONFIG_HOME=~/.helm/conf
export HELM_DATA_HOME=~/.helm/data
export HELM_CACHE_HOME=~/.helm/cache

export myself=$SOFTWARE_HOME/myself
export GOPROXY=https://goproxy.cn/,direct

export KUBE_EDITOR="code --wait"

export MVN_HOME=$SOFTWARE_HOME/apache-maven-3.6.3
export PROTOC_HOME=$SOFTWARE_HOME/protoc-3.14.0
export ISTIO_HOME=$SOFTWARE_HOME/istio-1.12.2
export CARGO_HOME=~/.cargo
export JMETER_HOME=$SOFTWARE_HOME/apache-jmeter-5.5
export PY_PATH="/Library/Frameworks/Python.framework/Versions/Current"

export PATH=$JMETER_HOME/bin:$MVN_HOME/bin:$ISTIO_HOME/bin:$PROTOC_HOME/bin:$GOPATH/bin:$SOFTWARE_HOME:~/script:$myself:$ETCD_HOME:$PATH

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH=$PATH:~/.dapr/bin

export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_333.jdk/Contents/Home
export JAVA_HOME=$JAVA_8_HOME
export PATH=$JAVA_HOME/bin:$CARGO_HOME/bin:$PATH:.
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
# export HOMEBREW_BOTTLE_DOMAIN=''

# brew install mysql-connector-c
# 可解决 pip3 install mysqlclient
export PATH="/usr/local/opt/mysql-client/bin:$PATH"
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"

export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"
export PATH="/Users/acejilam/Library/Application Support/JetBrains/Toolbox/scripts":$PATH

if [[ $(uname) == "Darwin" ]]; then
	alias readelf=greadelf
	alias objdump=gobjdump
	alias ping=gping
	alias sed=gsed
	alias find=gfind
	test -e ~/.k8sconfig || {
		echo '/Users/acejilam/.kube/koord' >~/.k8sconfig
	}
	export KUBECONFIG=$(cat ~/.k8sconfig)

	alias company_proxy='export https_proxy=http://172.20.3.242:7890 http_proxy=http://172.20.3.242:7890 all_proxy=socks5://172.20.3.242:7890'
	alias vlan_proxy="export https_proxy=http://$(ipconfig getifaddr en0):7890 http_proxy=http://$(ipconfig getifaddr en0):7890 all_proxy=socks5://$(ipconfig getifaddr en0):7890"
fi

alias grs='git add . && git reset --hard $((git show-ref --head --hash=8 2>/dev/null || echo 00000000) | head -n1) && git pull'
alias grep='\grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} '

alias gs='git status -sb'
alias gsa='git submodule add'
alias gst='git status'
alias gc='git checkout .'
alias ga='git add .'
alias gcb='git checkout -b'
alias gl='git pull'
alias gp='git push'
alias glog="git log --graph --pretty=format:'%Cred%h%Creset <--> %aI <--> %Cgreen(%ci)%Creset <--> %C(bold blue)<%an>%Creset <--> %s ' --abbrev-commit --date=relative"

alias cf="clang-format --style=\"file\" -i"
alias python39=python3

alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset https_proxy && unset http_proxy && unset all_proxy'

alias docker-clean-unused='docker system prune --all --force --volumes'
alias docker-clean-all='docker stop $(docker container ls -a -q) && docker system prune --all --force --volumes'

# GIT_SHA1=$( (git show-ref --head --hash=8 2>/dev/null || echo 00000000) | head -n1)
# GIT_DIRTY=$(git diff --no-ext-diff 2>/dev/null | wc -l)
# BUILD_ID=$(uname -n)"-"$(date +%s)

# autoload -Uz compinit
# compinit

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

test -e ~/.gopath/bin/kubectl || {
	curl -LO "https://files.m.daocloud.io/dl.k8s.io/release/$(curl -L -s https://files.m.daocloud.io/dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl"
	chmod +x kubectl
	mv kubectl ~/.gopath/bin/kubectl
}

if [[ "$SHELL" == *"bash" ]]; then
	source <(kubectl completion bash)
elif [[ "$SHELL" == *"zsh" ]]; then
	source <(kubectl completion zsh)
else
	echo "当前 shell 不是 Bash 或 Zsh"
fi

#### ffmpeg
# export PATH="/opt/homebrew/opt/ffmpeg@5/bin:$PATH"
# export LDFLAGS="-L/opt/homebrew/opt/ffmpeg@5/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/ffmpeg@5/include"
# export PKG_CONFIG_PATH="/opt/homebrew/opt/ffmpeg@5/lib/pkgconfig"

# alias vmip='curl -s --basic -u ls:Bg8q9DRnY2A0OLKw http://49.232.16.245/ip'

# To use the bundled libc++ please add the following LDFLAGS:
# export LDFLAGS="-L/usr/local/opt/llvm/lib"
# export CPPFLAGS="-I/usr/local/opt/llvm/include"

export K8S_DEBUG=1

# zsh 大小写敏感
# autoload -Uz compinit && compinit
# zstyle ':completion:*' matcher-list 'm:{a-z}={a-z}'
# source <(stern --completion=zsh)

alias ssh='trzsz --dragfile ssh'
# alias dive="docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
alias dive="docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock registry.cn-hangzhou.aliyuncs.com/acejilam/dive"

# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="robbyrussell"
# # git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
# # git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
# # git clone https://github.com/zsh-users/autojump ~/.oh-my-zsh/custom/plugins/autojump
# plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
# source $ZSH/oh-my-zsh.sh
# PROMPT='%B%(?:%F{green}➜ :%F{red}➜ )%f%{%}%F{red}%d%f%b%{%} %{$reset_color%}$(git_prompt_info)> '

# alias svm='ssh root@2j8g761566.wicp.vip -p 52575'

export GIT_EDITOR=code\ --wait
# git config --global core.editor code

# if [[ $(arch) != "arm64" ]]; then
#     export DOCKER_HOST='tcp://172.16.168.130:2375'
# fi

# 禁止生成.DS_store
# defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
alias k=\'kubectl\'
alias k8n='k get nodes'
alias k8ps='kubectl get pods -o "custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,NODE:.spec.nodeName,STATUS:.status.phase,RESOURCE_LIMIT:.spec.containers[*].resources.limits" -A '
alias k8nc='kubectl get node -o custom-columns=NAME:.metadata.name,RESOURCE_LIMIT:.status.capacity'
alias k8na='kubectl get node -o custom-columns=NAME:.metadata.name,RESOURCE_LIMIT:.status.allocatable'
# [[ -s "/Users/acejilam/.gvm/scripts/gvm" ]] && source "/Users/acejilam/.gvm/scripts/gvm"

# . "$HOME/.cargo/env"
# $()

# 修复运行 code . 报错
# codesign --force --deep --sign - /Applications/Visual\ Studio\ Code.app

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

export VAGRANT_DEFAULT_PROVIDER=vmware_fusion

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

export GONOPROXY='gitlab.datacanvas.com/*,git@gitlab.datacanvas.com/*'
export GOPRIVATE='gitlab.datacanvas.com/*,git@gitlab.datacanvas.com/*'
export GONOSUMDB='gitlab.datacanvas.com,git@gitlab.datacanvas.com'
