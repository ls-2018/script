echo '. /Users/acejilam/script/customer_script.sh' | tee -a ~/.bash_profile

echo '. /Users/acejilam/script/linux-bash.env' | tee -a ~/.bashrc
echo '. /Users/acejilam/script/customer_script.sh' | tee -a ~/.bashrc

echo '. /Users/acejilam/script/linux-zsh.env' | tee -a ~/.zshrc
echo '. /Users/acejilam/script/customer_script.sh' | tee -a ~/.zshrc

echo '. /Users/acejilam/script/customer_script.sh' | tee -a /etc/profile

# .zshenv：最早加载的文件，在所有 zsh 实例中都会执行，包括非交互式、登录、脚本环境等。它在 zsh 启动早期执行，还没加载 compinit，也不具备交互式 shell 的功能。
# .zshrc：只在交互式 shell 中执行，通常用来设置 prompt、alias、函数、compdef 等 shell 功能。
 