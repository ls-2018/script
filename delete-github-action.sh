#! /usr/bin/env bash
set -ex
echo "[cancel|delete] lsutils sync"
export ACTION=${1-a}
export OWNER=${2-lsutils}
export REPOSITORY=${3-sync}

if [[ $ACTION == "cancel" ]]; then
	gh api -X GET /repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000 | jq '.workflow_runs[1:] | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X POST repos/$OWNER/$REPOSITORY/actions/runs/{}/cancel'
elif [[ $ACTION == "delete" ]]; then
	gh api -X GET /repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000 | jq '.workflow_runs[1:] | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X DELETE /repos/$OWNER/$REPOSITORY/actions/runs/{}'
else
	echo "[cancel|delete] lsutils sync"
fi
