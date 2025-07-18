echo 'source /Users/acejilam/script/customer_script.sh' | tee -a ~/.bashrc
echo 'source /Users/acejilam/script/linux-env-bash.env' | tee -a ~/.bashrc

echo 'source /Users/acejilam/script/customer_script.sh' | tee -a /etc/profile
echo 'source /Users/acejilam/script/linux-env-bash.env' | tee -a /etc/profile

echo 'source /Users/acejilam/script/customer_script.sh' | tee -a ~/.zshrc
echo 'source /Users/acejilam/script/linux-env-zsh.env' | tee -a ~/.zshrc

echo 'source /Users/acejilam/script/customer_script.sh' | tee -a ~/.zprofile
echo 'source /Users/acejilam/script/linux-env-zsh.env' | tee -a ~/.zprofile

echo 'source /Users/acejilam/script/customer_script.sh' | tee -a ~/.zshenv
echo 'source /Users/acejilam/script/linux-env-zsh.env' | tee -a ~/.zshenv

# .zshenv ：最早加载的文件，在所有 zsh 实例中都会执行，包括非交互式、登录、脚本环境等。它在 zsh 启动早期执行，还没加载 compinit，也不具备交互式 shell 的功能。
# .zshrc ：只在交互式 shell 中执行，通常用来设置 prompt、alias、函数、compdef 等 shell 功能。
# Bash 登录 shell	            /etc/profile → ~/.bash_profile → ~/.bash_login → ~/.profile
# Bash 非登录交互式 shell        ~/.bashrc
# Zsh  登录 shell	            /etc/zprofile → ~/.zprofile → ~/.zlogin
# Zsh  交互式 shell	            /etc/zshrc → ~/.zshrc
# Zsh  非交互式 shell	        无自动加载（除非用 ZDOTDIR 指定）
