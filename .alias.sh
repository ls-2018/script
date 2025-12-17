#!/usr/bin/env bash

if [[ $(uname) == "Darwin" ]]; then
	alias docker='docker.py'
	alias git=git.py
	alias readelf=greadelf
	alias objdump=gobjdump
	# alias ping=gping
	alias sed=gsed
	alias find=gfind
	test -e ~/.k8sconfig || {
		echo '/Users/acejilam/.kube/kind-koord' >~/.k8sconfig
	}

	if [ -z "$KUBECONFIG" ]; then
		export KUBECONFIG=$(cat ~/.k8sconfig)
	fi

	alias vlan_proxy="export https_proxy=http://$(ipconfig getifaddr en0):7890 http_proxy=http://$(ipconfig getifaddr en0):7890 all_proxy=socks5://$(ipconfig getifaddr en0):7890"
	print_proxy.py check
fi

alias company_proxy='export http_proxy=http://hproxy.it.zetyun.cn:1080; export https_proxy=http://hproxy.it.zetyun.cn:1080;'

alias ga='git add .'
alias grs='git add . && \git reset --hard $((git show-ref --head --hash=8 2>/dev/null || echo 00000000) | head -n1) && \git pull'
alias grep='\grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} '

alias gs='\git status -sb'
alias gsa='\git submodule add'
alias gst='\git status'
alias gc='\git checkout .'
alias gcb='\git checkout -b'
alias gl='\git pull'
alias gp='\git push'
alias glog="\git log --graph --pretty=format:'%Cred%h%Creset <--> %aI <--> %Cgreen(%ci)%Creset <--> %C(bold blue)<%an>%Creset <--> %s ' --abbrev-commit --date=relative"

alias cf="clang-format --style=\"file\" -i"
alias python39=python3

alias proxy='export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890'
alias unproxy='unset https_proxy && unset http_proxy && unset all_proxy'

alias docker-clean-unused='docker system prune --all --force --volumes'
alias docker-clean-all='docker stop $(docker container ls -a -q) && docker system prune --all --force --volumes'

# alias ssh='trzsz --dragfile ssh'
# alias dive="docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
alias dive="docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock $(trans_image_name.py docker.io/wagoodman/dive)"

# Only run Zsh completion commands if we're in Zsh and compdef is available
if [ -n "$ZSH_VERSION" ] && type compdef >/dev/null 2>&1; then
	# https://github.com/stern/stern
	command -v stern >/dev/null 2>&1 && source <(stern --completion=zsh)
	command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)
	compdef kubecolor=kubectl
	export KUBECOLOR_PRESET="protanopia-dark"
fi

alias k=\'kubecolor\'
alias k8n='k get nodes'
alias k8ps='k8s-pod-state'
alias k8ns='k8s-node-cap'
k8pi() {
	namespace="$1"
	k get pods -n "${namespace}" -o jsonpath="{range .items[*]}{range .spec.containers[*]}{.image}{\"\n\"}{end}{end}" | sort | uniq
}
k8pir() {
	namespace="$1"
	k get pods -n "${namespace}" -o jsonpath="{range .items[*]}{range .spec.containers[*]}{.image}{\"\n\"}{end}{end}" | sort | uniq | trans_image_name_reverse.py
}

k8pidiff() {
	k8pi >/tmp/k8pi.txt
	cat /tmp/k8pi.txt | trans_image_name_reverse.py >/tmp/k8pir.txt
	git --no-pager diff /tmp/k8pi.txt /tmp/k8pir.txt
}

k8login() {
	cluster="$1"
	login_online.py -c "$cluster" && source /tmp/k8s_config.sh
}
alias sk='source /tmp/k8s_config.sh'

gtp() {
	git add .
	git commit -s -m "$1"
	git push --force
	git tag -d "$1"
	git tag "$1"
	git push --tags --force
}

fix_path_spaces() {
	local fixed_path=""
	local IFS=':' # 分隔 PATH 变量
	for entry in $PATH; do
		# 如果路径中含空格，则转义空格
		entry_fixed=$(echo "$entry" | sed 's/ /\\ /g')
		if [ -z "$fixed_path" ]; then
			fixed_path="$entry_fixed"
		else
			fixed_path="$fixed_path:$entry_fixed"
		fi
	done

	export PATH="$fixed_path"
}

alias mk="minikube kubectl --"

# delete_dir() {
# 	set -x
# 	find . -depth -type d -name "$1" -print -exec rm -rf {} \;
# }

delete_dir() { # 适用 zsh
	local target="$1"
	local dirs
	dirs=$(find . -depth -type d -name "$target")

	if [ -z "$dirs" ]; then
		echo "未找到目录 $target"
		return
	fi

	# 遍历每个目录
	while IFS= read -r dir; do
		while true; do
			read -q "ans?是否删除目录 '$dir'? [y/N] "
			echo
			case "$ans" in
			[yY])
				rm -rf -- "$dir"
				echo "已删除: $dir"
				break
				;;
			[nN] | '')
				echo "跳过: $dir"
				break
				;;
			*)
				echo "请输入 y 或 n"
				;;
			esac
		done
	done <<<"$dirs"
}

record() {
	local asciinema_file
	asciinema_file=$(date +%s)

	# 开始录制，用户做完事情输入 exit 即可
	asciinema rec "${asciinema_file}.cast"

	# 录制结束后，自动转换并生成 gif
	asciinema convert -f asciicast-v2 "${asciinema_file}.cast" "${asciinema_file}.cast2" --overwrite
	agg --font-family 'MesloLGS NF' "${asciinema_file}.cast2" "${asciinema_file}.gif"

	# 清理临时文件
	rm -f "${asciinema_file}.cast" "${asciinema_file}.cast2"

	echo "✅ 录制完成，已生成: ${asciinema_file}.gif"
}
