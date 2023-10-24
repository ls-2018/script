test -e "/Users/acejilam/.gvm/bin/gvm" || {
    sh -c "$(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"
    git config --global url."https://github.com/".insteadof git://github.com/
    source ~/.gvm/scripts/gvm
}

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

go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.42.1
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

go install sigs.k8s.io/apiserver-builder-alpha/cmd/apiserver-boot@v1.23.0

go install k8s.io/code-generator/cmd/{applyconfiguration-gen,defaulter-gen,client-gen,lister-gen,informer-gen,deepcopy-gen}@latest

# 代码 --> 汇编
go install loov.dev/lensm@main

# etcd
go install github.com/br0xen/boltbrowser@latest

go get -u github.com/go-bindata/go-bindata/...
go install github.com/cilium/ebpf/cmd/bpf2go@latest
go install github.com/mattn/goveralls@a36c7ef8f23b2952fa6e39663f52107dfc8ad69d # v0.0.11
go install github.com/mfridman/tparse@28967170dce4f9f13de77ec857f7aed4c4294a5f # v0.12.3 (main) with -progress

# tools
go install github.com/trzsz/trzsz-go/cmd/...@latest
