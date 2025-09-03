set -ex

# git config --global url."https://ghproxy.net/https://github.com".insteadOf "https://github.com"
cd /Volumes/Tf/resources/3rd/aya && time cargo install --path ./aya-tool/ && cd - || exit

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

rustup target add wasm32-wasi
