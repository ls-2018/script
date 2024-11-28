#!/usr/bin/env zsh

sudo apt install curl build-essential gcc make git -y
sudo curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf >rust.sh && chmod +x rust.sh

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

cat <<EOF >>/etc/profile
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
EOF

cat <<EOF >>$HOME/.bashrc
. "\$HOME/.cargo/env"
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
EOF

bash rust.sh -y

source /etc/profile
source $HOME/.bashrc

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
target-dir = "/Users/acejilam/.cargo/target"

EOF

# apt install pkg-config libssl-dev -y

# https://github.com/taiki-e/cargo-llvm-cov?tab=readme-ov-file#installation
cargo +stable install cargo-llvm-cov --locked

# https://github.com/cargo-bins/cargo-binstall
cargo install cargo-binstall

# https://github.com/nextest-rs/nextest
cargo install cargo-nextest

cargo install cargo-generate

cargo install bindgen-cli

# linux 有用
cargo install --git https://github.com/aya-rs/aya -- aya-tool

rustup override set nightly
