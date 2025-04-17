echo '. /Users/acejilam/script/customer_script.sh' | tee -a ~/.bash_profile
echo '. /Users/acejilam/script/customer_script.sh' | tee -a ~/.bashrc
echo '. /Users/acejilam/script/customer_script.sh' | tee -a /etc/profile
set +x
. /Users/acejilam/script/customer_script.sh
set -x
