set -x
cp -rf /resources/sh/p10k.zsh /root/.p10k.zsh
mkdir -p ~/.local/share/fonts


apt install fonts-firacode fonts-powerline -y # 可选

apt install zsh fontconfig -y

chsh -s $(which zsh)
echo $SHELL

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

cp -rf /resources/3rd/powerlevel10k                 ~/.oh-my-zsh/custom/themes/powerlevel10k
cp -rf /resources/3rd/zsh-autosuggestions           ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
cp -rf /resources/3rd/zsh-syntax-highlighting       ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
cp -rf /resources/ttf/*                             ~/.local/share/fonts/

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
