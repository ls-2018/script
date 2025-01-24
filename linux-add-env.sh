echo '. /Users/acejilam/script/customer_script.sh' | tee -a ~/.bash_profile
echo '. /Users/acejilam/script/customer_script.sh' | tee -a ~/.bashrc
echo '. /Users/acejilam/script/customer_script.sh' | tee -a /etc/profile
echo 'export GITHUB_PROXY=https://ghproxy.cn/' | tee -a /etc/profile
set +x
. /Users/acejilam/script/customer_script.sh
set -x
export GITHUB_PROXY="https://ghproxy.cn/"
git config --global url."${GITHUB_PROXY}https://github.com".insteadOf https://github.com
