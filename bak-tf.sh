cd /Volumes/Tf/
tree ./skip >skip.txt

bak() {
	rsync -avzP --progress --delete --delete-excluded --filter=':- .gitignore' --exclude-from=/Volumes/Tf/config/exclude.txt /Volumes/Tf/ /Users/acejilam/Documents/TfBak
	# --iconv=gbk,utf-8//TRANSLIT

	mkdir -p /Users/acejilam/data/wechat
	rsync -avzP --progress --delete /Users/acejilam/Documents/wechat/* /Users/acejilam/data/wechat
	# --iconv=gbk,utf-8//TRANSLIT
}

bak
bak
bak
