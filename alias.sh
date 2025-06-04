if [[ $(uname) == "Darwin" ]]; then
	alias git=git.py
	alias readelf=greadelf
	alias objdump=gobjdump
	alias ping=gping
	alias sed=gsed
	alias find=gfind
	test -e ~/.k8sconfig || {
		echo '/Users/acejilam/.kube/kind-koord' >~/.k8sconfig
	}

	if [ -z "$KUBECONFIG" ]; then
		export KUBECONFIG=$(cat ~/.k8sconfig)
	fi

	alias vlan_proxy="export https_proxy=http://$(ipconfig getifaddr en0):7890 http_proxy=http://$(ipconfig getifaddr en0):7890 all_proxy=socks5://$(ipconfig getifaddr en0):7890"
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

alias ssh='trzsz --dragfile ssh'
# alias dive="docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
alias dive="docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock registry.cn-hangzhou.aliyuncs.com/acejilam/dive"

alias k=\'kubectl\'
alias k8n='k get nodes'
alias k8ps='kubectl get pods -o "custom-columns=NAME:.metadata.name,NAMESPACE:.metadata.namespace,NODE:.spec.nodeName,STATUS:.status.phase,RESOURCE_LIMIT:.spec.containers[*].resources.limits" -A '
alias k8nc='kubectl get node -o custom-columns=NAME:.metadata.name,RESOURCE_LIMIT:.status.capacity'
alias k8na='kubectl get node -o custom-columns=NAME:.metadata.name,RESOURCE_LIMIT:.status.allocatable'

# alias vmip='curl -s --basic -u ls:Bg8q9DRnY2A0OLKw http://49.232.16.245/ip'

# alias svm='ssh root@2j8g761566.wicp.vip -p 52575'

gtp() {
	git add .
	git commit -s -m "$1"
	git push --force
	git tag -d "$1"
	git tag "$1"
	git push --tags --force
}
