#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys
import importlib.util
import requests

def import_from_path(path: str, module_name: str = None):
    if module_name is None:
        module_name = f"module_{abs(hash(path))}"

    spec = importlib.util.spec_from_file_location(module_name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module

m=import_from_path(os.path.join(os.path.dirname(os.path.abspath(__file__)),"trans_image_name.py"))

 

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

with open(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "linux-install-zsh-docker.sh"),
        'r',
        encoding='utf8'
) as f:
    install_zsh = f.read()

install_source = '''
rm -rf /usr/local/go* || echo 1
rm -rf ./go*  		  || echo 1
curl -sSL https://linuxmirrors.cn/main.sh | bash -s -- \
    --source mirrors.tencent.com \
    --protocol https \
    --use-intranet-source false \
    --install-epel true \
    --backup true \
    --upgrade-software false \
    --clean-cache false \
    --ignore-backup-tips
'''

install_kubectl = '''
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
'''

install_system_bin = '''
set -x
apt update -y
apt install wget git gcc curl locales -y
apt install vim make cmake gdb -y
apt install telnet dnsutils upx iproute2 net-tools -y

'''

img = m.trans_image('docker.io/library/ubuntu:24.04')
dockerfile = f'''
FROM {img}
COPY localtime /etc/localtime
WORKDIR /build
# ENV LANG=en_US.UTF-8
# ENV LANGUAGE=en_US:en
# ENV LC_ALL=en_US.UTF-8
ENV TZ=Asia/Shanghai

ENV DEBIAN_FRONTEND=noninteractive

ENV CGO_ENABLED="0"
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
ENV GOROOT=/usr/local/go${{VERSION}}
ENV GOPATH=/root/.gopath
ENV GOBIN=/usr/local/go${{VERSION}}/bin
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go${{VERSION}}/bin

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

shutil.copyfile(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), 'localtime'),
    os.path.join(build_path, 'localtime')
)

really_version = version
if really_version == 'latest':
    res = requests.get("https://golang.google.cn/dl/?mode=json")
    really_version = res.json()[0]['version'].strip('go')

for k, v in dict(globals()).items():
    if k.startswith('install_'):
        with open(f'{build_path}/{k}.sh', 'w') as f:
            f.write(v.replace('${VERSION}', really_version))
    if k == "dockerfile":
        with open(f'{build_path}/Dockerfile', 'w') as f:
            f.write(v.replace('${VERSION}', really_version))

with open(f'{build_path}/.dockerignore', 'w') as f:
    f.write('Dockerfile\n')

if version == 'latest':
    tag_version = 'latest'
else:
    tag_version = f'v{version}'

build_script = f'''
cd {build_path}
docker buildx build \
--platform linux/arm64,linux/amd64 \
--cache-from=type=registry,ref={repo}/mygo:{tag_version} \
--cache-to=type=inline \
--pull -t {repo}/mygo:{tag_version} --push .
'''

print(build_script)
result = subprocess.run(build_script, shell=True)
if result.returncode != 0:
    sys.exit(result.returncode)
print(f'{repo}/mygo:v{version}')
