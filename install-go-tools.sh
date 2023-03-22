sh -c "$(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"
git config --global url."https://github.com/".insteadof git://github.com/
source ~/.gvm/scripts/gvm

GO111MODULE=on
GOPROXY=https://goproxy.cn,direct
set -x
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/lint/golint@latest
go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
go install github.com/BurntSushi/toml/cmd/tomlv@latest
go install github.com/go-critic/go-critic/...@latest
go install github.com/go-lintpack/lintpack/...@latest
go install github.com/quasilyte/go-ruleguard/cmd/ruleguard@latest
go install github.com/quasilyte/go-ruleguard/dsl@latest

go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.41.1
go install mvdan.cc/gofumpt@latest
go install github.com/go-delve/delve/cmd/dlv@master
go get -v -u github.com/googleapis/gax-go/v2
go install github.com/wtfutil/wtf@latest
go install github.com/kisielk/godepgraph@latest
# 单测生成的覆盖文件转换成xml/html格式的覆盖率文件
go install github.com/axw/gocov/gocov@latest
go install github.com/matm/gocov-html/cmd/gocov-html@latest
go install github.com/AlekSi/gocov-xml@latest

# diff-cover[3]，生成行增量覆盖率
#yum -y install gcc automake autoconf libtool make zlib zlib-devel openssl openssl-devel
#wget https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz
#tar -zxvf Python-3.8.1.tgz && cd Python-3.8.1 && ./configure && make && make install
# pip3 install diff-cover -i https://mirrors.aliyun.com/pypi/simpl

go install github.com/google/wire/cmd/wire@latest

# test
go get github.com/smartystreets/goconvey

# neth
go install github.com/microsoft/ethr@latest

# vscode font
cd /Library/Fonts
rm -rf Menlo-for-Powerline
git clone https://github.com/abertsch/Menlo-for-Powerline.git
