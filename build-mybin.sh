#! /usr/bin/env zsh
expand() {
  mkdir -p /tmp/cargo-expand/
  echo '''
  # syntax=docker/dockerfile:1.7
  FROM ccr.ccs.tencentyun.com/ls-2018/myrust AS builder

  ARG TARGETARCH

  RUN if [ "$TARGETARCH" = "amd64" ]; then \
          rustup target add x86_64-unknown-linux-musl ; \
      elif [ "$TARGETARCH" = "arm64" ]; then \
          rustup target add aarch64-unknown-linux-musl ; \
      fi

  # 克隆代码
  RUN git clone https://github.com/dtolnay/cargo-expand.git
  WORKDIR /cargo-expand

  # 构建
  RUN if [ "$TARGETARCH" = "amd64" ]; then \
          cargo build --release --target x86_64-unknown-linux-musl ; \
      elif [ "$TARGETARCH" = "arm64" ]; then \
          cargo build --release --target aarch64-unknown-linux-musl ; \
      fi

  # 导出阶段
  FROM scratch AS export
  ARG TARGETARCH
  COPY --from=builder /cargo-expand/target/*/release/cargo-expand /cargo-expand
  ''' >/tmp/cargo-expand/Dockerfile

  cd /tmp/cargo-expand
  docker buildx build --platform linux/amd64,linux/arm64 --output type=local,dest=./out .

  mkdir -p /Users/acejilam/script/binary
  cp -rf /tmp/cargo-expand/out/linux_amd64/cargo-expand /Users/acejilam/script/binary/cargo-expand-x86_64
  cp -rf /tmp/cargo-expand/out/linux_arm64/cargo-expand /Users/acejilam/script/binary/cargo-expand-aarch64

  md5sum /tmp/cargo-expand/out/linux_amd64/cargo-expand
  md5sum /Users/acejilam/script/binary/cargo-expand-x86_64

  md5sum /tmp/cargo-expand/out/linux_arm64/cargo-expand
  md5sum /Users/acejilam/script/binary/cargo-expand-aarch64

}

#expand

generate() {
  mkdir -p /tmp/cargo-generate/
  echo '''
  # syntax=docker/dockerfile:1.7
  FROM ccr.ccs.tencentyun.com/ls-2018/myrust AS builder

  ARG TARGETARCH

  RUN if [ "$TARGETARCH" = "amd64" ]; then \
          rustup target add x86_64-unknown-linux-musl ; \
      elif [ "$TARGETARCH" = "arm64" ]; then \
          rustup target add aarch64-unknown-linux-musl ; \
      fi

  # 克隆代码
  RUN git clone https://github.com/cargo-generate/cargo-generate.git
  WORKDIR /cargo-generate

  # 构建
  RUN if [ "$TARGETARCH" = "amd64" ]; then \
          cargo build --release --target x86_64-unknown-linux-musl ; \
      elif [ "$TARGETARCH" = "arm64" ]; then \
          cargo build --release --target aarch64-unknown-linux-musl ; \
      fi

  # 导出阶段
  FROM scratch AS export
  ARG TARGETARCH
  COPY --from=builder /cargo-generate/target/*/release/cargo-generate /cargo-generate
  ''' >/tmp/cargo-generate/Dockerfile

  cd /tmp/cargo-generate
  docker buildx build --platform linux/amd64,linux/arm64 --output type=local,dest=./out .

  mkdir -p /Users/acejilam/script/binary
  cp -rf /tmp/cargo-generate/out/linux_amd64/cargo-generate /Users/acejilam/script/binary/cargo-generate-x86_64
  cp -rf /tmp/cargo-generate/out/linux_arm64/cargo-generate /Users/acejilam/script/binary/cargo-generate-aarch64

  md5sum /tmp/cargo-generate/out/linux_amd64/cargo-generate
  md5sum /Users/acejilam/script/binary/cargo-generate-x86_64

  md5sum /tmp/cargo-generate/out/linux_arm64/cargo-generate
  md5sum /Users/acejilam/script/binary/cargo-generate-aarch64

}

generate
