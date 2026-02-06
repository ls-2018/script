ln -s /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code /usr/local/bin/code

git config --global --add safe.directory /opt/homebrew/Library/Taps/homebrew/homebrew-core
git config --global --add safe.directory /opt/homebrew/Library/Taps/homebrew/homebrew-cask

# export HOMEBREW_BOTTLE_DOMAIN=''
brew install pkg-config
brew install skopeo
brew install llvm
brew install wget
brew install jq
brew install yq
brew install lima
brew install git
brew install unix2dos
brew install telnet
brew install gsed
brew install findutils # gfind
brew install tree
brew install harfbuzz
brew install graphviz
brew install tokei
brew install mysql
brew install protobuf
brew install ctop
brew install make
brew install bash
chsh -s /opt/homebrew/bin/bash
brew install zsh
chsh -s /bin/zsh
brew install zsh-syntax-highlighting
brew install zsh-autosuggestions
brew install zsh-completions
brew update && brew install binutils
# k8s log 工具
brew install stern
brew install kubecm
# https://cmake.org/download/
# sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install

export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
cd /tmp
git clone https://gitee.com/ls-2018/lscpu.git
cd lscpu
make
sudo cp lscpu /usr/local/bin
cd ..
rm -rf /tmp/lscpu

## 安装字体
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts
unset https_proxy && unset http_proxy && unset https_proxy

cd /tmp
wget --no-verbose https://zenlayer.dl.sourceforge.net/project/sshpass/sshpass/1.10/sshpass-1.10.tar.gz
tar -zxvf sshpass-1.10.tar.gz
cd sshpass-1.10
./configure
make && make install
mv ./sshpass /usr/local/bin/

# brew tap hashicorp/tap
# brew install hashicorp/tap/hashicorp-vagrant
# # 制作box 镜像
# brew tap hashicorp/tap
# brew install hashicorp/tap/packer

# grpc test、bench
brew install ghz

brew install FiloSottile/musl-cross/musl-cross
brew install mingw-w64

brew tap tinygo-org/tools
brew install tinygo
brew install gping

brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant
brew install --cask vagrant-vmware-utility
brew install gcc libffi openssl
vagrant plugin install vagrant-vmware-desktop

brew install gh
brew install devspace

brew install git-lfs

brew install coreutils wget cmake libtool go automake ninja clang-format bazel

brew install snipaste
brew install windterm

# dockerfile 格式化
brew install hadolint

brew install chipmk/tap/docker-mac-net-connect

(
	set -x
	cd "$(mktemp -d)" &&
		OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
		ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
		KREW="krew-${OS}_${ARCH}" &&
		curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
		tar zxvf "${KREW}.tar.gz" &&
		./"${KREW}" install krew
	rm -rf ./krew-${OS}_${ARCH}
)

brew install helm
brew install helmfile

helm plugin install https://github.com/databus23/helm-diff




# 解决orbstack 设置proxy 后无法拉取镜像
brew install dnscrypt-proxy
sudo brew services start dnscrypt-proxy
#  Set the system DNS to 127.0.0.1