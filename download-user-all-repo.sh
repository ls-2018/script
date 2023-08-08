#!/bin/bash
#CNTX={users|orgs};
#NAME={username|orgname};
#CNTX=users
#CNTX=orgs
set -e
echo 'who?={users|orgs} type={users|orgs} '
if [ "$1" == "" ]; then
  exit
fi

if [ "$2" == "" ]; then
  exit
fi

CNTX=$2
mkdir -p "$1" || echo $1
cd "$1" || exit

for ((PAGE = 1; PAGE <= 100; PAGE++)); do
  curl -s "https://api.github.com/$CNTX/$1/repos?page=$PAGE&per_page=1000" |
    grep -e 'clone_url*' | cut -d \" -f 4 | xargs -I F -L1 git clone F || echo F 'exists'
done
