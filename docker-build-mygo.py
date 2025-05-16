#!/usr/bin/env python3
import os
import shutil
import sys

build_path = '/tmp/build-mygo'

install_go = '''
set -ex
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go${VERSION}/bin
mkdir /usr/local/go${VERSION}

ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

wget https://golang.google.cn/dl/go${VERSION}.linux-$ARCH.tar.gz
tar -xvf go${VERSION}.linux-$ARCH.tar.gz -C /usr/local/go${VERSION} --strip-components 1
rm -rf go${VERSION}.linux-$ARCH.tar.gz
mkdir -p /root/.gopath/{bin,src,pkg}
chmod -R 777 /usr/local/go${VERSION}

go version
go env

'''

install_go_bin = '''
go install github.com/trzsz/trzsz-go/cmd/...@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/rakyll/hey@latest
'''

install_zsh = '''
cp ./.p10k.zsh /root/.p10k.zsh
apt install zsh fontconfig -y 
chsh -s $(which zsh)
echo $SHELL

echo y |sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git        ~/.oh-my-zsh/custom/themes/powerlevel10k
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

'''

install_source = '''
rm -rf /usr/local/go* || echo 1
rm -rf ./go*  		  || echo 1
rm -rf /etc/apt/sources.list.d/gierens.list
sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/* 
sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list 
sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/* 
sed -i "s@http://.*ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
sed -i "s@http://.*ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*
apt update -y 
'''

install_kubectl = '''
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
'''

install_system_bin = '''
apt install wget git gcc curl locales fonts-powerline -y
apt install vim wget make cmake gdb -y


'''
dockerfile = '''
FROM registry.cn-hangzhou.aliyuncs.com/acejilam/ubuntu:24.04
WORKDIR /build
# ENV LANG=en_US.UTF-8
# ENV LANGUAGE=en_US:en
# ENV LC_ALL=en_US.UTF-8
ENV TZ=Asia/Shanghai

ENV DEBIAN_FRONTEND=noninteractive

ENV CGO_ENABLED="0"
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
ENV GOROOT=/usr/local/go${VERSION}
ENV GOPATH=/root/.gopath
ENV GOBIN=/usr/local/go${VERSION}/bin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go${VERSION}/bin

COPY . .

RUN bash install_source.sh
RUN bash install_system_bin.sh
RUN bash install_kubectl.sh
RUN bash install_zsh.sh
RUN bash install_go.sh
RUN bash install_go_bin.sh

WORKDIR /
RUN rm -rf /build
CMD ["zsh"]
'''

print('docker buildx create --use --name mygo')
try:
    shutil.rmtree(build_path, ignore_errors=True)
    os.mkdir(build_path)
except:
    pass
version = sys.argv[1].strip('v ')
repo = sys.argv[2].strip('')

shutil.copyfile(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), '.p10k.zsh'),
    os.path.join(build_path, '.p10k.zsh')
)

for k, v in dict(globals()).items():
    if k.startswith('install_'):
        with open(f'{build_path}/{k}.sh', 'w') as f:
            f.write(v.replace('${VERSION}', version))
    if k == "dockerfile":
        with open(f'{build_path}/Dockerfile', 'w') as f:
            f.write(v.replace('${VERSION}', version))
#
# os.system(f'cd {build_path} && ' + \
#           f'docker buildx build --platform linux/arm64,linux/amd64 --pull -t {repo}/mygo:v{version}-test --push . ')
# print(f'{repo}/mygo:v{version}')
