set -ex
cp -rf /resources/sh/p10k.zsh /root/.p10k.zsh
mkdir -p ~/.local/share/fonts

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "arm64" = ${ARCH} ]; then
	cat /resources/tar/arm64/gitstatusd-linux-aarch64.tar.gz | tar -zxvf - && chmod +x ./gitstatusd-linux-aarch64 && mv gitstatusd-linux-aarch64 /usr/bin/gitstatusd
else
	cat /resources/tar/arm64/gitstatusd-linux-x86_64.tar.gz | tar -zxvf - && chmod +x ./gitstatusd-linux-x86_64 && mv gitstatusd-linux-x86_64 /usr/bin/gitstatusd
fi

apt install fonts-firacode fonts-powerline -y # 可选

apt install zsh fontconfig -y

chsh -s $(which zsh)
echo $SHELL

REMOTE=https://gitee.com/ls-2018/ohmyzsh.git \
	sh -c /resources/sh/install-zsh.sh "" --unattended

cp -rf /resources/3rd/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
cp -rf /resources/3rd/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
cp -rf /resources/3rd/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
cp -rf /resources/ttf/* ~/.local/share/fonts/

fc-cache -fv

echo "✓ Testing Powerlevel10k Icons:  ⚡ ❯"

cat >~/.zshrc <<EOF

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    z
)
source ~/.oh-my-zsh/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

EOF
