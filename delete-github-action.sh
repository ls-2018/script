#! /usr/bin/env bash
set -ex
echo "[cancel|delete] lsutils sync"
export ACTION=${1-a}
export OWNER=${2-lsutils}
export REPOSITORY=${3-sync}
export ALL=${4-0}

if [[ $ACTION == "cancel" ]]; then
	if [[ $ALL -eq "all" ]]; then
		gh api -X GET /repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000 | jq '.workflow_runs | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X POST repos/$OWNER/$REPOSITORY/actions/runs/{}/cancel'
	else
		gh api -X GET /repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000 | jq '.workflow_runs[1:] | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X POST repos/$OWNER/$REPOSITORY/actions/runs/{}/cancel'
	fi
elif [[ $ACTION == "delete" ]]; then
	if [[ $ALL -eq "all" ]]; then
		gh api -X GET /repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000 | jq '.workflow_runs | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X DELETE /repos/$OWNER/$REPOSITORY/actions/runs/{}'
	else
		gh api -X GET /repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000 | jq '.workflow_runs[1:] | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X DELETE /repos/$OWNER/$REPOSITORY/actions/runs/{}'
	fi
else
	echo "[cancel|delete] lsutils sync"
fi
