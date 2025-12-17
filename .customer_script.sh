#!/usr/bin/env bash

ACEHOME="/Users/acejilam"
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE:-$0}")" && pwd)"

# setopt no_nomatch
export GOPATH=${ACEHOME}/.gopath
export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk

mkdir -p $GOPATH/{bin,pkg,src}
mkdir -p ${ACEHOME}/.cargo/{target,registry,git}
# export RUSTC_WRAPPER=sccache

# Mac
# CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build main.go
# windows
# CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
# Linux
# CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build main.go

# https://zhuanlan.zhihu.com/p/383707713
SOFTWARE_HOME=${ACEHOME}/software
export HELM_CONFIG_HOME=${ACEHOME}/.helm/conf
export HELM_DATA_HOME=${ACEHOME}/.helm/data
export HELM_CACHE_HOME=${ACEHOME}/.helm/cache

export myself=$SOFTWARE_HOME/myself
export GOPROXY=https://goproxy.cn/,direct

export KUBE_EDITOR="code --wait"

export MVN_HOME=$SOFTWARE_HOME/apache-maven-3.6.3
export PROTOC_HOME=$SOFTWARE_HOME/protoc-3.14.0
export ISTIO_HOME=$SOFTWARE_HOME/istio-1.12.2
export JMETER_HOME=$SOFTWARE_HOME/apache-jmeter-5.5
export PY_PATH="/Library/Frameworks/Python.framework/Versions/Current"

export PATH=$JMETER_HOME/bin:$MVN_HOME/bin:$ISTIO_HOME/bin:$PROTOC_HOME/bin:$GOPATH/bin:$SOFTWARE_HOME:${ACEHOME}/script:$myself:$ETCD_HOME:$PATH

export PATH="$ACEHOME/.npm/node_modules/.bin:$ACEHOME/.yarn/bin:$ACEHOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="${KREW_ROOT:-$ACEHOME/.krew}/bin:$PATH"
export PATH=$PATH:${ACEHOME}/.dapr/bin

test -e /opt/homebrew/bin/brew && {
	export CARGO_HOME=${ACEHOME}/.cargo
	export JAVA_HOME=$(brew --prefix openjdk)
	export PATH=$JAVA_HOME/bin:$CARGO_HOME/bin:$PATH
	export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
	export CPATH="$(brew --prefix leveldb)/include"
	export LIBRARY_PATH="$(brew --prefix leveldb)/lib"
}

export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
# export HOMEBREW_BOTTLE_DOMAIN=''

# brew install mysql-connector-c
# 可解决 pip3 install mysqlclient

export PATH="/usr/local/opt/mysql-client/bin:$PATH"
export PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH:$HOME/.atuin/bin"
# To use the bundled libc++ please add the following LDFLAGS:
# export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"

# GIT_SHA1=$( (git show-ref --head --hash=8 2>/dev/null || echo 00000000) | head -n1)
# GIT_DIRTY=$(git diff --no-ext-diff 2>/dev/null | wc -l)
# BUILD_ID=$(uname -n)"-"$(date +%s)

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [[ $(uname) == "Darwin" ]]; then
	. "$SCRIPT_DIR/.alias.sh"
	test -e ${ACEHOME}/.gopath/bin/kubectl || {
		curl -LO "https://files.m.daocloud.io/dl.k8s.io/release/$(curl -L -s https://files.m.daocloud.io/dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl"
		chmod +x kubectl
		mv kubectl ${ACEHOME}/.gopath/bin/kubectl
	}

	test -e /usr/local/bin/iterm2-zmodem || {
		sudo cp ~/script/iterm2-zmodem.sh /usr/local/bin/iterm2-zmodem
		sudo chmod +x /usr/local/bin/iterm2-zmodem
	}
fi

#### ffmpeg
# export PATH="/opt/homebrew/opt/ffmpeg@5/bin:$PATH"
# export LDFLAGS="-L/opt/homebrew/opt/ffmpeg@5/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/ffmpeg@5/include"
# export PKG_CONFIG_PATH="/opt/homebrew/opt/ffmpeg@5/lib/pkgconfig"

export K8S_DEBUG=1

export GIT_EDITOR=code\ --wait
# git config --global core.editor code

# if [[ $(arch) != "arm64" ]]; then
#     export DOCKER_HOST='tcp://172.16.168.130:2375'
# fi

# 禁止生成.DS_store
# defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

# 修复运行 code . 报错
# codesign --force --deep --sign - /Applications/Visual\ Studio\ Code.app

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

export VAGRANT_DEFAULT_PROVIDER=vmware_fusion

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

export GONOPROXY='gitlab.datacanvas.com/*,git@gitlab.datacanvas.com/*'
export GOPRIVATE='gitlab.datacanvas.com/*,git@gitlab.datacanvas.com/*'
export GONOSUMDB='gitlab.datacanvas.com,git@gitlab.datacanvas.com'
export GOFLAGS='-buildvcs=false'

if test -d "/Volumes/Tf"; then
	mkdir -p /Volumes/Tf/config
	export HISTFILE="/Volumes/Tf/config/zsh_history"
else
	export HISTFILE="/Users/acejilam/Documents/TfBak/config/zsh_history"
fi

export PYTHONPATH=$SCRIPT_DIR:$PYTHONPATH

# zsh 通配符无匹配时报错
# setopt +o nomatch

# find ~ -maxdepth 1 -name '.zcompdump*' -exec rm -rf {} + 2>/dev/null
# find ~ -maxdepth 1 -name '.java*' -exec rm -rf {} + 2>/dev/null
# find ~ -maxdepth 1 -name '.wget*' -exec rm -rf {} + 2>/dev/null
# find ~ -maxdepth 1 -name 'jcef_*' -exec rm -rf {} + 2>/dev/null

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

skopeo_copy() {
	source_image=$1
	dest_image=$2
	echo $source_image '    ➡️ ➡️ ➡️ ➡️    ' $dest_image
	set -x
	skopeo copy --all --insecure-policy docker://$source_image docker://${dest_image} "${@:3}"
	set +x
}

alias sc='skopeo_copy.py'

parse_cert() {
	cert=$1
	echo $cert | base64 -d >/tmp/cert.txt
	openssl x509 -noout -text -in /tmp/cert.txt
}
