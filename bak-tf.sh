rsync -avzP --progress --delete --exclude-from=/Volumes/Tf/config/exclude.txt /Volumes/Tf/ /Users/acejilam/Documents/TfBak
# --iconv=gbk,utf-8//TRANSLIT

mkdir -p /Volumes/Tf/data/wechat
rsync -avzP --progress --delete /Users/acejilam/Documents/wechat/* /Volumes/Tf/data/wechat
# --iconv=gbk,utf-8//TRANSLIT
