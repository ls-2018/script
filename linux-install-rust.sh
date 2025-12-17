export DEBIAN_FRONTEND=noninteractive

mkdir -p ~/.cargo/{target,registry}
touch ~/.cargo/env

sudo apt install curl build-essential gcc make git pkg-config libssl-dev -y

cat <<EOF >>"$HOME"/.cargo/env
# 临时设置环境变量以替换默认更新源和分发服务器
export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup

export PATH=~/.cargo/target/release:\$PATH
export PATH=~/.cargo/target/debug:\$PATH
EOF

. "$HOME"/.cargo/env

cp /Volumes/Tf/resources/sh/install-rust.sh install-rust.sh && chmod +x install-rust.sh

./install-rust.sh -y

cat <<EOF >"$HOME"/.cargo/config.toml
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

#replace-with = 'rsproxy'
replace-with = 'aliyun'

[source.aliyun]
registry = "sparse+https://mirrors.aliyun.com/crates.io-index/"

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
target-dir = "$HOME/.cargo/target"

EOF

export PATH="$HOME/.cargo/bin:$PATH"

# unset RUSTC_WRAPPER

#共享缓存
# time cargo install sccache

# linux 有用

apt install pkg-config libssl-dev -y

# bash /Users/acejilam/script/init-rust.sh
