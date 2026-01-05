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
	echo -e "\033[32m✅ ${*//x/\\033[31mx\\033[32m}\033[0m"
}

warn() {
	echo -e "\033[33m⚠️  ${*//x/\\033[31mx\\033[33m}\033[0m" >&2
}

fail() {
	echo -e "\033[31m❌ ${*//x/\\033[31mx}\033[0m" >&2
}

install_sccache() {
	# 获取最新版本号
	tag=$(curl -fsSL https://api.github.com/repos/mozilla/sccache/releases/latest | jq -r '.tag_name')

	# 确定系统架构和操作系统
	os=$(uname -s | tr '[:upper:]' '[:lower:]')
	arch=$(uname -m)

	# 确定下载包名称
	tar_name=""
	if [ "$os" = "darwin" ] && [ "$arch" = "x86_64" ]; then
		tar_name="sccache-${tag}-x86_64-apple-darwin.tar.gz"
	elif [ "$os" = "darwin" ] && [ "$arch" = "arm64" ]; then
		tar_name="sccache-${tag}-aarch64-apple-darwin.tar.gz"
	elif [ "$os" = "linux" ] && [ "$arch" = "aarch64" ]; then
		tar_name="sccache-${tag}-aarch64-unknown-linux-musl.tar.gz"
	elif [ "$os" = "linux" ] && [ "$arch" = "x86_64" ]; then
		tar_name="sccache-${tag}-x86_64-unknown-linux-musl.tar.gz"
	fi

	# 检查是否支持当前系统
	if [ -z "$tar_name" ]; then
		fail "不支持的操作系统或架构: $os $arch"
		return 1
	fi

	# 下载并安装 sccache
	temp_dir=$(mktemp -d)
	wget -q -nv -O "${temp_dir}/${tar_name}" "https://github.com/mozilla/sccache/releases/download/${tag}/${tar_name}"
	tar -xzf "${temp_dir}/${tar_name}" -C "${temp_dir}"
	extracted_dir=$(ls -1 "${temp_dir}" | grep -v tar | grep sccache-)
	if [ -f "${temp_dir}/${extracted_dir}/sccache" ]; then
		chmod +x "${temp_dir}/${extracted_dir}/sccache"
		mv "${temp_dir}/${extracted_dir}/sccache" "$HOME/.cargo/bin/"
		ok "sccache 安装成功，版本: ${tag}"
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
	# 获取最新版本号
	tag=$(curl -fsSL https://api.github.com/repos/cargo-generate/cargo-generate/releases/latest | jq -r '.tag_name')

	# 确定系统架构和操作系统
	os=$(uname -s | tr '[:upper:]' '[:lower:]')
	arch=$(uname -m)

	# 确定下载包名称
	tar_name=""
	if [ "$os" = "darwin" ] && [ "$arch" = "x86_64" ]; then
		tar_name="cargo-generate-${tag}-x86_64-apple-darwin.tar.gz"
	elif [ "$os" = "darwin" ] && [ "$arch" = "arm64" ]; then
		tar_name="cargo-generate-${tag}-aarch64-apple-darwin.tar.gz"
	elif [ "$os" = "linux" ] && [ "$arch" = "aarch64" ]; then
		tar_name="cargo-generate-${tag}-aarch64-unknown-linux-musl.tar.gz"
	elif [ "$os" = "linux" ] && [ "$arch" = "x86_64" ]; then
		tar_name="cargo-generate-${tag}-x86_64-unknown-linux-gnu.tar.gz"
	fi

	# 检查是否支持当前系统
	if [ -z "$tar_name" ]; then
		fail "不支持的操作系统或架构: $os $arch"
		return 1
	fi

	# 下载并安装 cargo-generate
	temp_dir=$(mktemp -d)
	wget -q -nv -O "${temp_dir}/${tar_name}" "https://github.com/cargo-generate/cargo-generate/releases/download/${tag}/${tar_name}"
	tar -xzf "${temp_dir}/${tar_name}" -C "${temp_dir}"
	if [ -f "${temp_dir}/cargo-generate" ]; then
		chmod +x "${temp_dir}/cargo-generate"
		mv "${temp_dir}/cargo-generate" "$HOME/.cargo/bin/"
		ok "cargo-generate 安装成功，版本: ${tag}"
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
	git clone https://github.com/dtolnay/cargo-expand.git
	cd cargo-expand
	echo '
  [build]
  rustc-wrapper = "sccache"
  ' >>Cargo.toml
	RUSTC_WRAPPER="sccache" cargo install --path .
	cd -
	rm -rf cargo-expand
}

install_expand
sccache --zero-stats && cargo clean

rm -rf /root/.cargo/{git,registry,target}
