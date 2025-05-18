# 会在容器内执行


wget -O /root/.p10k.zsh https://raw.githubusercontent.com/ls-2018/script/refs/heads/main/.p10k.zsh
apt install fonts-firacode fonts-powerline -y  # 可选

apt install zsh fontconfig -y

chsh -s $(which zsh)
echo $SHELL


echo y |sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1https://github.com/romkatv/powerlevel10k.git        ~/.oh-my-zsh/custom/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions              ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git      ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget -O "MesloLGS NF Regular.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
wget -O "MesloLGS NF Bold.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
wget -O "MesloLGS NF Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
wget -O "MesloLGS NF Bold Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
fc-cache -fv
cd -

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