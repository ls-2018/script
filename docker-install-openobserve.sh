set -e
docker rm openobserve --force
cd ~
homePath=$(pwd)
dataPath="$homePath/data/openobserve"
cd -

docker run -d \
	--name openobserve \
	-v $dataPath:/data \
	-p 5080:5080 -p 5081:5081 \
	-e ZO_ROOT_USER_EMAIL="root@example.com" \
	-e ZO_ROOT_USER_PASSWORD="Complexpass#123" \
	$(trans-image-name public.ecr.aws/zinclabs/openobserve)
open -a '/Applications/Google Chrome.app' http://127.0.0.1:5080
