export DEBIAN_FRONTEND=noninteractive

mkdir -p ~/.cargo/{target,registry}
touch ~/.cargo/env

apt install curl build-essential gcc make git pkg-config libssl-dev jq -y

cat <<EOF >>"$HOME"/.cargo/env
# 临时设置环境变量以替换默认更新源和分发服务器
export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup

export PATH=~/.cargo/target/release:\$PATH
export PATH=~/.cargo/target/debug:\$PATH
EOF

. "$HOME"/.cargo/env

wget -q -nv https://mirrors.aliyun.com/repo/rust/rustup-init.sh && chmod +x rustup-init.sh && bash ./rustup-init.sh -y

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
#target-dir = "$HOME/.cargo/target"
#rustc-wrapper = "sccache"
EOF

# export RUSTC_WRAPPER="sccache"
# sccache --zero-stats && cargo clean && cargo build

export PATH="$HOME/.cargo/bin:$PATH"

# linux 有用
apt install pkg-config libssl-dev -y

# bash /Users/acejilam/script/init-rust.sh

ok() {
	printf "\033[32m✅ %s\033[0m\n" "$*"
}

warn() {
	printf "\033[33m⚠️ %s\033[0m\n" "$*"
}

fail() {
	printf "\033[31m❌ %s\033[0m\n" "$*"
}

# 确定系统架构和操作系统
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
base="https://gitee.com/ls-2018/script/raw/main/binary"

install_sccache() {
	# 下载并安装 sccache
	temp_dir=$(mktemp -d)
	cd $temp_dir
	wget -q -nv $base/sccache-$arch
	if [ -f "${temp_dir}/sccache-$arch" ]; then
		chmod +x "${temp_dir}/sccache-$arch"
		mv "${temp_dir}/sccache-$arch" "$HOME/.cargo/bin/sccache"
		ok "sccache 安装成功,版本: ${tag}"
	else
		fail "sccache 安装失败"
		rm -rf "${temp_dir}"
		return 1
	fi

	# 清理临时文件
	rm -rf "${temp_dir}"
}

install_sccache

install_generate() {
	# 下载并安装 generate
	temp_dir=$(mktemp -d)
	cd $temp_dir
	wget -q -nv $base/cargo-generate-$arch
	if [ -f "${temp_dir}/cargo-generate-$arch" ]; then
		chmod +x "${temp_dir}/cargo-generate-$arch"
		mv "${temp_dir}/cargo-generate-$arch" "$HOME/.cargo/bin/cargo-generate"
		ok "cargo-generate 安装成功,版本: ${tag}"
	else
		fail "cargo-generate 安装失败"
		rm -rf "${temp_dir}"
		return 1
	fi

	# 清理临时文件
	rm -rf "${temp_dir}"
}

install_generate

install_expand() {
	temp_dir=$(mktemp -d)
	cd $temp_dir
	wget -q -nv $base/cargo-expand-$arch
	if [ -f "${temp_dir}/cargo-expand-$arch" ]; then
		chmod +x "${temp_dir}/cargo-expand-$arch"
		mv "${temp_dir}/cargo-expand-$arch" "$HOME/.cargo/bin/cargo-expand"
		ok "cargo-expand 安装成功,版本: ${tag}"
	else
		fail "cargo-expand 安装失败"
		rm -rf "${temp_dir}"
		return 1
	fi

	# 清理临时文件
	rm -rf "${temp_dir}"
}

install_expand
sccache --zero-stats
