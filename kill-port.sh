if [ $# -eq 0 ]; then
	exit 1
else
	port=$1
fi
lsof -i:$port | grep -v COMMAND | grep -v 'com.docke' | awk '{print $2}' | xargs kill -9
