#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys

build_path = '/tmp/build-myrust'

with open(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "linux-install-rust.sh"),
        'r',
        encoding='utf8'
) as f:
    install_rust = f.read()

install_rust_bin = '''
rustup override set stable
rustup toolchain uninstall nightly
rustup toolchain install nightly

'''

with open(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "linux-install-zsh-docker.sh"),
        'r',
        encoding='utf8'
) as f:
    install_zsh = f.read()

install_source = '''
apt clean
dpkg -i *.deb
bash change_mirror.sh \
    --source mirrors.tencent.com \
    --protocol https \
    --use-intranet-source false \
    --install-epel true \
    --backup true \
    --upgrade-software false \
    --clean-cache true \
    --ignore-backup-tips
 
'''

install_kubectl = '''
ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
wget -q -nv "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$(uname | tr '[:upper:]' '[:lower:]')/${ARCH}/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
'''

install_system_bin = '''
set -x
apt install -y \
	wget git gcc curl locales \
	vim make cmake gdb \
	telnet dnsutils upx iproute2 net-tools
'''

dockerfile = f'''
FROM docker.io/library/ubuntu:24.04 AS ca
RUN apt update -y && apt-get install --download-only ca-certificates -y

FROM alpine/curl:8.17.0 AS curl
WORKDIR /root
RUN curl -o change_mirror.sh https://linuxmirrors.cn/main.sh

FROM docker.io/library/ubuntu:24.04 AS base
COPY localtime /etc/localtime
WORKDIR /build
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
ENV CGO_ENABLED="0"
ENV GO111MODULE=on
ENV PATH=/root/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY . .
 
COPY --from=curl /root/change_mirror.sh .
COPY --from=ca /var/cache/apt/archives/*.deb .
RUN bash install_source.sh
RUN bash install_system_bin.sh
RUN bash install_kubectl.sh
RUN bash install_zsh.sh
RUN bash install_rust.sh && bash install_rust_bin.sh && rm -rf /root/.cargo/{{git,registry,target}}
WORKDIR /
RUN rm -rf /build
CMD ["zsh"]

'''

print('docker buildx create --use --name myrust')
try:
    shutil.rmtree(build_path, ignore_errors=True)
    os.mkdir(build_path)
except:
    pass


repo = sys.argv[1].strip('')

shutil.copyfile(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), '.p10k.zsh'),
    os.path.join(build_path, '.p10k.zsh')
)

shutil.copyfile(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), 'localtime'),
    os.path.join(build_path, 'localtime')
)

for k, v in dict(globals()).items():
    if k.startswith('install_'):
        with open(f'{build_path}/{k}.sh', 'w') as f:
            f.write(v)
    if k == "dockerfile":
        with open(f'{build_path}/Dockerfile', 'w') as f:
            f.write(v)

with open(f'{build_path}/.dockerignore', 'w') as f:
    f.write('Dockerfile\n')

tag_version = 'latest'

build_script = f'''
cd {build_path}
docker buildx build \
--platform linux/arm64,linux/amd64 \
--cache-from=type=registry,ref={repo}/myrust:{tag_version} \
--cache-to=type=inline \
--pull -t {repo}/myrust:{tag_version} --push .
'''

print('Start build image...')
with open(f'{build_path}/Dockerfile', 'r', encoding='utf8') as f:
    print(f.read(), flush=True)

print(build_script, flush=True)
result = subprocess.run(build_script, shell=True)
if result.returncode != 0:
    sys.exit(result.returncode)

print(f'{repo}/myrust:{tag_version}')
