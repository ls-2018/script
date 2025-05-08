set -ex
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
