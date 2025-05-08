#!/bin/bash

# 设置GitHub仓库和访问令牌
GITHUB_REPO=${1-lsutils/kind}
echo $GITHUB_REPO
GITHUB_TOKEN=$(gh auth token)

# 获取仓库的所有tags
tags_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/tags")

# 提取所有tag名称
tags_to_delete=$(echo "$tags_response" | jq -r '.[].name' | sort)

# 删除除最新以外的所有tags
for tag in $tags_to_delete; do
	echo "Deleting tag: $tag"
	curl -X DELETE -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$GITHUB_REPO/git/refs/tags/$tag"
done
