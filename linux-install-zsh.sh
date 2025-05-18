# 会在容器内执行

cp -rf /resources/sh/p10k.zsh /root/.p10k.zsh
apt install fonts-firacode fonts-powerline -y  # 可选

apt install zsh fontconfig -y

chsh -s $(which zsh)
echo $SHELL

echo y |sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cp /resources/3rd/powerlevel10k             ~/.oh-my-zsh/custom/themes/powerlevel10k
cp /resources/3rd/zsh-autosuggestions       ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
cp /resources/3rd/zsh-syntax-highlighting   ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

mkdir -p ~/.local/share/fonts
cp /resources/ttf/* ~/.local/share/fonts
fc-cache -fv

echo "✓ Testing Powerlevel10k Icons:  ⚡ ❯"

cat > ~/.zshrc <<EOF

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