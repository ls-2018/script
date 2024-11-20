#! /usr/bin/env bash
set -ex

export OWNER=${1-lsutils}
export REPOSITORY=${2-sync}

gh api -X GET /repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000 | jq '.workflow_runs[1:] | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X DELETE /repos/$OWNER/$REPOSITORY/actions/runs/{}'
gh api -X GET /repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000 | jq '.workflow_runs[1:] | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X POST repos/$OWNER/$REPOSITORY/actions/runs/{}/cancel'
