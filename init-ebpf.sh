#! /usr/bin/env zsh
name=${1-learning-ebpf}

limactl delete $name -f
rm -rf /tmp/$name.yaml
cp -rf ~/script/learning-ebpf.yaml /tmp/$name.yaml

sed -i "s#PWD#$(pwd)#" /tmp/$name.yaml
sed -i "s#HOSTNAME#${name}#" /tmp/$name.yaml

limactl start /tmp/$name.yaml # --debug --log-level=debug

echo ✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️✈️

echo "limactl shell $name sudo bash -c 'cd $(pwd) && bash'"
limactl shell $name sudo bash -c "cd $(pwd) && bash"
