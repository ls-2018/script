# 会在容器内执行

wget -O ~/.p10k.zsh https://gitee.com/ls-2018/script/raw/main/.p10k.zsh
apt install fonts-firacode fonts-powerline git -y # 可选

mkdir -p ~/.cache/gitstatus/
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
if [ "arm64" = ${ARCH} ]; then
	wget -qO- https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-aarch64.tar.gz | tar -zxvf - && chmod +x ./gitstatusd-linux-aarch64 && mv gitstatusd-linux-aarch64 ~/.cache/gitstatus/
else
	wget -qO- https://github.com/romkatv/gitstatus/releases/download/v1.5.4/gitstatusd-linux-x86_64.tar.gz | tar -zxvf - && chmod +x ./gitstatusd-linux-x86_64 && mv gitstatusd-linux-x86_64 ~/.cache/gitstatus/
fi

apt install zsh fontconfig -y

chsh -s $(which zsh)

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget -O "MesloLGS NF Regular.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
wget -O "MesloLGS NF Bold.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
wget -O "MesloLGS NF Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
wget -O "MesloLGS NF Bold Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
fc-cache -fv
cd -

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
