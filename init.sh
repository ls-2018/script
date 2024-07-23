ln -s /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code /usr/local/bin/code

git config --global --add safe.directory /opt/homebrew/Library/Taps/homebrew/homebrew-core
git config --global --add safe.directory /opt/homebrew/Library/Taps/homebrew/homebrew-cask

# export HOMEBREW_BOTTLE_DOMAIN=''
brew install pkg-config
brew install skopeo
brew install llvm
brew install jq
brew install unix2dos
brew install telnet
brew install gsed
brew install tree
brew install harfbuzz
brew install graphviz
brew install tokei
brew install mysql
brew install protobuf
brew install ctop
brew install zsh
chsh -s /bin/zsh
brew install zsh-syntax-highlighting
brew install zsh-autosuggestions
brew install zsh-completions
brew update && brew install binutils
# k8s log 工具
brew install stern
# https://cmake.org/download/
# sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install

cd /tmp
git clone https://github.com/NanXiao/lscpu.git
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

cd /tmp
wget https://zenlayer.dl.sourceforge.net/project/sshpass/sshpass/1.10/sshpass-1.10.tar.gz
tar -zxvf sshpass-1.10.tar.gz
cd sshpass-1.10
./configure
make && make install
mv ./sshpass /usr/local/bin/



brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant
# 制作box 镜像
brew tap hashicorp/tap
brew install hashicorp/tap/packer
