#!/bin/bash

# 检查并安装所需工具
install_tool() {
	local tool=$1
	if ! cargo install --list | grep -q "$tool"; then
		echo "安装 $tool ..."
		cargo install "$tool"
	else
		echo "$tool 已安装"
	fi
}
rustup override set stable

echo "确保所需工具已安装..."
install_tool cargo-udeps
install_tool cargo-sort
install_tool cargo-outdated

echo "切换到nightly工具链以支持 cargo-udeps ..."

# 识别并移除未使用的crate
echo "识别未使用的crate..."
cargo +nightly udeps || {
	echo "未能检测未使用的crate，检查nightly版本或项目依赖"
}

# 排序并格式化Cargo.toml中的依赖
echo "排序和格式化Cargo.toml依赖项..."
cargo sort || {
	echo "Cargo.toml 排序失败"
}

# 检查并列出过时的依赖项
echo "检查过时的依赖项..."
cargo outdated || {
	echo "无法列出过时依赖，检查cargo-outdated是否正确安装"
}

# 恢复为默认工具链
echo "恢复为stable工具链..."
rustup override unset

# 格式化代码
echo "格式化Rust代码..."
rustup component add rustfmt
cargo fmt

echo "依赖管理任务完成！"
