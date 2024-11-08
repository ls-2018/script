# #!/bin/bash
# rm -rf /etc/apt/sources.list.d/*

# ARCH=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)

# if [[ $ARCH == "amd64" ]]; then
#     cat >/etc/apt/sources.list <<EOF
# Types: deb
# URIs: http://mirrors.tuna.tsinghua.edu.cn/ubuntu
# Suites: noble-security
# Components: main universe restricted multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
# EOF
# fi

# if [[ $ARCH == "arm64" ]]; then
#     cat >/etc/apt/sources.list <<EOF
# Types: deb
# URIs: http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/
# Suites: noble noble-updates noble-security
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
# EOF
# fi
