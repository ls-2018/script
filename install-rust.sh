#!/usr/bin/env zsh

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

sudo apt install curl build-essential gcc make -y 
sudo curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf > rust.sh && chmod +x rust.sh 

bash rust.sh -y

# cat << EOF >> /etc/profile
# . "\$HOME/.cargo/env"
# EOF

cat << EOF > ~/.cargo/config.toml
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


# https://github.com/taiki-e/cargo-llvm-cov?tab=readme-ov-file#installation
cargo +stable install cargo-llvm-cov --locked

# https://github.com/cargo-bins/cargo-binstall
brew install cargo-binstall

# https://github.com/nextest-rs/nextest
brew install cargo-nextest

brew install cargo-generate

cargo install bindgen-cli

# linux 有用
cargo install --git https://github.com/aya-rs/aya -- aya-tool


rustup override set nightly