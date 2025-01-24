#!/usr/bin/env zsh

vmPath='/Users/acejilam/Desktop/vm'

cd ${vmPath}
vagrant destroy -f
rm -rf ${vmPath}/*
rm -rf /tmp/vm*

vagrant global-status --prune
pkill -9 vmware-vmx
pkill -9 vagrant

ln -s ~/script/Vagrantfile ${vmPath}/Vagrantfile
ln -s ~/script/Vagrantfile-single ${vmPath}/Vagrantfile-single

# echo -e "vm2204\nvm2404" | xargs -P 2 -I {} vagrant up {}
cd ${vmPath}

{vagrant up vm2204 && touch /tmp/vm2204.success} &
{vagrant up vm2404 && touch /tmp/vm2404.success} &

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

util::wait_context_exist /tmp/vm2204.success
util::wait_context_exist /tmp/vm2404.success
