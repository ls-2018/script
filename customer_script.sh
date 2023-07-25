setopt no_nomatch
export GOPATH=~/.gopath
export GO111MODULE=on
# export CGO_ENABLED=1
export CGO_CFLAGS=-Wno-undef-prefix
export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
export CC=clang
export GOOS=darwin
export GOARCH=amd64
go env -w GOPATH=/Users/acejilam/.gopath
ldflags='-compressdwarf=false'
mkdir -p $GOPATH/{bin,pkg,src}

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
alias sed=gsed

export myself=$SOFTWARE_HOME/myself
# export GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
export GOPROXY=https://goproxy.cn/,direct

export KUBE_EDITOR="code --wait"

export MVN_HOME=$SOFTWARE_HOME/apache-maven-3.6.3
export PROTOC_HOME=$SOFTWARE_HOME/protoc-3.14.0
export ISTIO_HOME=$SOFTWARE_HOME/istio-1.12.2
#export ETCD_HOME=$SOFTWARE_HOME/etcd-v3.4.9
export JMETER_HOME=$SOFTWARE_HOME/apache-jmeter-5.5
export PY_PATH="/Library/Frameworks/Python.framework/Versions/Current"

export PATH=$JMETER_HOME/bin:$MVN_HOME/bin:$ISTIO_HOME/bin:$PROTOC_HOME/bin:$GOPATH/bin:$SOFTWARE_HOME:~/script:$myself:$ETCD_HOME:$PATH

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH=$PATH:~/.dapr/bin

export JAVA_8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_333.jdk/Contents/Home
export JAVA_HOME=$JAVA_8_HOME
export PATH=$JAVA_HOME/bin:$PATH:.
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

export PATH="/Library/Frameworks/Python.framework/Versions/3.9/bin/:$PATH"

export ETCD_USER='root'
export ETCD_PASSWORD='YTGEHfPCGGIIOVT1'

# export REDIS_USER='root'
export REDIS_PASSWORD='c4ca4238a0b923820dcc509a6f75849b'

alias k="kubectl"
alias ks="kubectl -n kube-system"
alias km="kubectl -n mesoid"

# brew update && brew install binutils
alias readelf=greadelf
alias objdump=gobjdump
alias ping=gping

# export MASTERIP=$(get_current_cluster_master_ip.py)

export GITEE_USER=1214972346@qq.com
export GITEE_PASSWORD=1214972346@aA
alias gs='git status -sb'
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

source /Users/acejilam/.gvm/scripts/gvm

prompt_context() {}

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
# autoload -Uz compinit
# compinit

# GIT_SHA1=$( (git show-ref --head --hash=8 2>/dev/null || echo 00000000) | head -n1)
# GIT_DIRTY=$(git diff --no-ext-diff 2>/dev/null | wc -l)
# BUILD_ID=$(uname -n)"-"$(date +%s)

alias grs='git add . && git reset --hard $((git show-ref --head --hash=8 2>/dev/null || echo 00000000) | head -n1) && git pull'

alias mk='kubectl --kubeconfig=/Users/acejilam/.kube/75.config'
alias ck='kubectl --kubeconfig=/Users/acejilam/.kube/517.config'
alias vk='kubectl --kubeconfig=/Users/acejilam/.kube/vcluster.config'
alias grep='\grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} -v grep|\grep'

source <(kubectl completion zsh)
alias kx=\'kubectl\'
complete -F __start_kubectl kx

alias k='kubectl --kubeconfig=/Users/acejilam/.kube/myconfig'
alias ck='kubectl --kubeconfig=/Users/acejilam/.kube/company_config'

#### ffmpeg
export PATH="/opt/homebrew/opt/ffmpeg@5/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/ffmpeg@5/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ffmpeg@5/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/ffmpeg@5/lib/pkgconfig"
