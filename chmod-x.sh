if [ $# -eq 0 ]; then
	curPath=$(dirname "$0")
else
	curPath=$1
fi

echo $curPath
find $curPath | grep '\.sh' | xargs chmod +x
find $curPath | grep '\.py' | xargs chmod +x
