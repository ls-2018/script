FROM registry.cn-hangzhou.aliyuncs.com/acejilam/ubuntu:24.04

# 设置非交互模式
ENV DEBIAN_FRONTEND=noninteractive
# 设置语言环境
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

ENV TZ=Asia/Shanghai

RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN sed -i "s@http://.*archive.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*
RUN sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN sed -i "s@http://.*security.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*
RUN sed -i "s@http://.*ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN sed -i "s@http://.*ports.ubuntu.com@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list.d/*
RUN sed -i "s@deb https://mirrors.bfsu.edu.cn@# deb http://mirrors.bfsu.edu.cn@g" /etc/apt/sources.list
RUN sed -i "s@deb https://mirrors.bfsu.edu.cn@# deb http://mirrors.bfsu.edu.cn@g" /etc/apt/sources.list.d/*



# 安装必要的软件包
RUN apt update && apt install -y \
    git \
    curl \
    zsh \
    locales \
    fonts-powerline \
    vim wget make cmake gdb zsh fontconfig \
    && locale-gen en_US.UTF-8

WORKDIR /root
COPY . .
RUN bash wget.sh
RUN bash cfg.sh
# 设置默认 shell
CMD ["zsh"]
