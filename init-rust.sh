set -ex

rustup override set stable
rustup toolchain uninstall nightly
rustup toolchain install nightly

# git config --global url."https://ghproxy.net/https://github.com".insteadOf "https://github.com"
if test -d "/Volumes/Tf/resources/3rd/aya"; then
	cp /Volumes/Tf/resources/3rd/aya ./aya
	cd aya && time cargo install --path ./aya-tool/ && cd - || exit
	rm -rf aya
else
	git clone https://github.com/aya-rs/aya aya
	cd aya && time cargo install --path ./aya-tool/ && cd - || exit
	rm -rf aya
fi

# 终端录屏工具
cargo install --locked --git https://github.com/asciinema/asciinema
# 转成svg
cargo install --locked --git https://github.com/asciinema/agg

# git config --global --unset url."https://ghproxy.net/https://github.com".insteadOf

# https://github.com/taiki-e/cargo-llvm-cov?tab=readme-ov-file#installation
time cargo +stable install cargo-llvm-cov --locked

# https://github.com/cargo-bins/cargo-binstall
time cargo install cargo-binstall

# https://github.com/nextest-rs/nextest
time cargo install cargo-nextest

time cargo install cargo-generate

time cargo install bindgen-cli

# rustup override set nightly
# rustup override set stable

#可视化模块树
time cargo install cargo-modules

#展开宏
time cargo install cargo-expand

# rust -> wasm
time cargo install wasm-pack

# rustup target add wasm32-wasi

# 清理由 Cargo 生成的未使用的构建文件。与cargo clean不同
# cargo-sweep旨在保留那些在不同版本间不会发生变化的文件，从而提高构建效率。
cargo install cargo-sweep

# 会扫描 Rust 项目的Cargo.lock文件，检查已知的漏洞和依赖的安全问题。
cargo install cargo-audit

# 找出并移除那些吃灰的依赖
cargo install cargo-udeps

# 会按照字母顺序对dependencies、dev-dependencies等进行排序，并将排序结果写回Cargo.toml中。
cargo install cargo-sort

# 查看哪些 crate 有新版本
cargo install cargo-outdated

cargo install cargo-cache
