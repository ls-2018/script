#!/usr/bin/env zsh
mkdir -p ~/.cargo/{target,registry}
touch ~/.cargo/env

echo 'nameserver 114.114.114.114' >/etc/resolv.conf
resolvectl dns eth0 114.114.114.114
resolvectl dns eth1 114.114.114.114

sudo apt install curl build-essential gcc make git pkg-config libssl-dev -y

cat <<EOF >>~/.bash_profile
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export PATH=/root/.cargo/target/release:\$PATH
export PATH=/root/.cargo/target/debug:\$PATH
. "\$HOME/.cargo/env"
EOF

source ~/.bash_profile

sudo curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf >rust.sh && chmod +x rust.sh
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
bash rust.sh -y

cat <<EOF >$HOME/.cargo/config.toml
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

#replace-with = 'rsproxy'
# 中国科学技术大学
replace-with = 'ustc'

# rsproxy
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"

[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

# 清华大学
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

# 中国科学技术大学
[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index/"

# 上海交通大学
[source.sjtu]
registry = "https://mirrors.sjtug.sjtu.edu.cn/git/crates.io-index"

# rustcc社区
[source.rustcc]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"

[net]
git-fetch-with-cli=true

[build]
#target-dir = "/root/.cargo/target"

EOF

unset RUSTC_WRAPPER

#共享缓存
# time cargo install sccache

# linux 有用
git config --global url."https://ghproxy.net/https://github.com".insteadOf "https://github.com"
cd /resources/3rd/aya && time cargo install --path ./aya-tool/ && cd -
git config --global --unset url."https://ghproxy.net/https://github.com".insteadOf

# apt install pkg-config libssl-dev -y

bash /Users/acejilam/script/init-rust.sh
