test -e "/Users/acejilam/.gvm/bin/gvm" || {
	export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
	sh -c "$(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"
	git config --global url."https://github.com/".insteadof git://github.com/
	source ~/.gvm/scripts/gvm
	unset https_proxy && unset http_proxy && unset all_proxy
}

test -e /Library/Fonts/Menlo-for-Powerline || {
	export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890
	# vscode font
	cd /Library/Fonts
	rm -rf Menlo-for-Powerline
	git clone https://github.com/abertsch/Menlo-for-Powerline.git
	unset https_proxy && unset http_proxy && unset all_proxy
}

GO111MODULE=on
GOPROXY=https://goproxy.cn,direct
set -x
go install golang.org/x/tools/cmd/goimports@latest
go install golang.org/x/lint/golint@latest
go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
go install github.com/BurntSushi/toml/cmd/tomlv@latest
go install github.com/ServiceWeaver/weaver/cmd/weaver@latest
go install github.com/go-critic/go-critic/...@latest
go install github.com/go-lintpack/lintpack/...@latest
go install github.com/quasilyte/go-ruleguard/cmd/ruleguard@latest

go install sigs.k8s.io/kind@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@latest
go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest

go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install mvdan.cc/gofumpt@latest
go install github.com/go-delve/delve/cmd/dlv@master
go install github.com/googleapis/gax-go/v2@latest
go install github.com/wtfutil/wtf@latest
go install github.com/kisielk/godepgraph@latest
# 单测生成的覆盖文件转换成xml/html格式的覆盖率文件
go install github.com/axw/gocov/gocov@latest
go install github.com/matm/gocov-html/cmd/gocov-html@latest
go install github.com/AlekSi/gocov-xml@latest

# diff-cover[3]，生成行增量覆盖率
#yum -y install gcc automake autoconf libtool make zlib zlib-devel openssl openssl-devel
#wget --no-verbose https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz
#tar -zxvf Python-3.8.1.tgz && cd Python-3.8.1 && ./configure && make && make install
# pip3 install diff-cover -i https://mirrors.aliyun.com/pypi/simpl

go install github.com/google/wire/cmd/wire@latest

# test
go install github.com/smartystreets/goconvey@latest

# neth
go install github.com/microsoft/ethr@latest

go install sigs.k8s.io/apiserver-builder-alpha/cmd/apiserver-boot@v1.23.0

go install k8s.io/code-generator/cmd/{applyconfiguration-gen,defaulter-gen,client-gen,lister-gen,informer-gen,deepcopy-gen}@latest

# 代码 --> 汇编
go install loov.dev/lensm@main

# etcd
go install github.com/br0xen/boltbrowser@latest

go install github.com/go-bindata/go-bindata/...@latest
go install github.com/cilium/ebpf/cmd/bpf2go@latest
go install github.com/mattn/goveralls@a36c7ef8f23b2952fa6e39663f52107dfc8ad69d # v0.0.11
go install github.com/mfridman/tparse@28967170dce4f9f13de77ec857f7aed4c4294a5f # v0.12.3 (main) with -progress

# tools
go install github.com/trzsz/trzsz-go/cmd/...@latest

# cert
go install github.com/cloudflare/cfssl/cmd/...@latest

# k8s rbac
go install github.com/corneliusweig/rakkess@latest
# curl -LO https://github.com/corneliusweig/rakkess/releases/download/v0.5.0/rakkess-amd64-darwin.tar.gz &&
#     tar xf rakkess-amd64-darwin.tar.gz rakkess-amd64-darwin &&
#     chmod +x rakkess-amd64-darwin &&
#     mv -i rakkess-amd64-darwin $(go env GOPATH)/bin/rakkess

go install github.com/submariner-io/subctl/cmd@latest && mv ~/.gopath/bin/cmd ~/.gopath/bin/subctl

go install github.com/google/gops@latest

# go 函数执行顺序及时间打印
cd /tmp && git clone https://gitee.com/ls-2018/functrace.git && cd functrace/cmd/gen && go build . && mv gen ~/.gopath/bin/functrace && cd -

go install github.com/google/yamlfmt/cmd/yamlfmt@latest

cd /tmp && git clone https://github.com/lestrrat-go/jwx.git && cd jwx && make && cd -

go install github.com/goreleaser/goreleaser/v2@latest

go install github.com/davecheney/httpstat@latest

go install github.com/karalabe/xgo@latest