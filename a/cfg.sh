chsh -s $(which zsh)
echo $SHELL

cat > ~/.zshrc <<EOF
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    z
)
source /root/.oh-my-zsh/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# 设置 .zshrc，启用 powerlevel10k 主题
sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc

# 下载默认的 .p10k.zsh 配置文件
#curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-classic.zsh -o ~/.p10k.zsh
#curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-lean-8colors.zsh -o ~/.p10k.zsh
#curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-pure.zsh -o ~/.p10k.zsh
#curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-rainbow.zsh -o ~/.p10k.zsh
#curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-robbyrussell.zsh -o ~/.p10k.zsh
#echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> ~/.zshrc
