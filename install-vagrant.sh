#!/usr/bin/env zsh

#cat > ~/.ssh/config <<EOF
#Host vm2404
#  HostName vm2404
#  User root
#  IdentityFile ~/.ssh/id_ed25519
#  IdentitiesOnly yes
#EOF

vmPath='/Users/acejilam/Desktop/vm'

cd ${vmPath}
vagrant destroy -f
rm -rf ${vmPath}/*
rm -rf /tmp/vm*
mkdir -p ${vmPath}
vagrant global-status --prune
pkill -9 vmware-vmx
pkill -9 vagrant

ln -s ~/script/Vagrantfile ${vmPath}/Vagrantfile
ln -s ~/script/Vagrantfile-single ${vmPath}/Vagrantfile-single

# echo -e "vm2204\nvm2404" | xargs -P 2 -I {} vagrant up {}
cd ${vmPath}


for vm in $(vagrant status | grep vmware_fusion | awk '{print $1}'); do
	x=$vm 
  	echo "{vagrant up $x && touch /tmp/$x.success} &"
	{vagrant up $x && touch /tmp/$x.success} &
done


function util::wait_context_exist() {
	local file=${1}
	for ((time = 0; time < 3000; time++)); do
		if [ -e ${file} ]; then
			return 0
		fi
		sleep 1
	done
	return 1
}

for vm in $(vagrant status | grep vmware_fusion | awk '{print $1}'); do
	x=$vm 
	util::wait_context_exist /tmp/$x.success
done



cd /Users/acejilam/Desktop/vm
vagrant halt
vagrant snapshot save init
vagrant reload
