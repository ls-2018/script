FROM registry.cn-hangzhou.aliyuncs.com/acejilam/ubuntu:24.04

# 设置非交互模式
ENV DEBIAN_FRONTEND=noninteractive
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
    && locale-gen en_US.UTF-8

# 设置语言环境
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# 创建用户
RUN useradd -ms /bin/zsh devuser

USER devuser
WORKDIR /home/devuser


# 安装 oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 安装 powerlevel10k 主题
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/devuser/.oh-my-zsh/custom/themes/powerlevel10k

# 设置 .zshrc，启用 powerlevel10k 主题
RUN sed -i 's|ZSH_THEME=".*"|ZSH_THEME="powerlevel10k/powerlevel10k"|' /home/devuser/.zshrc

# 下载默认的 .p10k.zsh 配置文件
RUN #curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-classic.zsh -o /home/devuser/.p10k.zsh
RUN #curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-lean-8colors.zsh -o /home/devuser/.p10k.zsh
RUN #curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-pure.zsh -o /home/devuser/.p10k.zsh
RUN #curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-rainbow.zsh -o /home/devuser/.p10k.zsh
RUN curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/refs/heads/master/config/p10k-robbyrussell.zsh -o /home/devuser/.p10k.zsh
RUN echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> /home/devuser/.zshrc

# 确保所有权正确
RUN chown -R devuser:devuser /home/devuser

# 设置默认 shell
CMD ["zsh"]
