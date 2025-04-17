#!/usr/bin/env bash

r=$(git branch -r)

git branch -r | grep -v '\->' | while read remote; do
	branch="-> ${remote}"
	if [[ $res =~ $r ]]; then
		echo 12
	else
		# x="${remote#origin/}"
		# if [[ $x =~ $l ]]; then
		#     echo "存在本地分支" $branch
		# else
		git branch --track "$remote" -f
		# fi
	fi
done
git fetch --all
git pull --all
