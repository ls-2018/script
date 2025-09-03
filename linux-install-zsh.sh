#!/usr/bin/env bash
cp -rf /Volumes/Tf/resources/sh/p10k.zsh ~/.p10k.zsh
mkdir -p ~/.local/share/fonts

mkdir -p ~/.cache/gitstatus/
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "arm64" = ${ARCH} ]; then
	cat /Volumes/Tf/resources/tar/arm64/gitstatusd-linux-aarch64.tar.gz | tar -zxvf - && chmod +x ./gitstatusd-linux-aarch64 && mv gitstatusd-linux-aarch64 ~/.cache/gitstatus/
else
	cat /Volumes/Tf/resources/tar/amd64/gitstatusd-linux-x86_64.tar.gz | tar -zxvf - && chmod +x ./gitstatusd-linux-x86_64 && mv gitstatusd-linux-x86_64 ~/.cache/gitstatus/
fi

apt install fonts-firacode fonts-powerline -y # 可选

apt install zsh fontconfig -y

chsh -s $(which zsh)

for i in {0..255}; do
	REMOTE=https://gitee.com/ls-2018/ohmyzsh.git bash -c /Volumes/Tf/resources/sh/install-zsh.sh "" --unattended
	if [ $? == 0 ]; then
		break
	fi
	echo "Retrying Oh My Zsh installation..."
	sleep 2
done

cp -rf /Volumes/Tf/resources/3rd/powerlevel10k ~/.oh-my-zsh/custom/themes/powerlevel10k
cp -rf /Volumes/Tf/resources/3rd/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
cp -rf /Volumes/Tf/resources/3rd/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
cp -rf /Volumes/Tf/resources/ttf/* ~/.local/share/fonts/

fc-cache -fv

echo "✓ Testing Powerlevel10k Icons:  ⚡ ❯"

cat >~/.zshrc <<EOF
export ZSH="\$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    z
)
source \$ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
