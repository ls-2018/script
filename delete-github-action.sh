OWNER=${1-lsutils}
REPOSITORY=${2-/root/sync}

gh api -X GET "/repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000" | jq '.workflow_runs[1:] | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X POST repos/$OWNER/$REPOSITORY/actions/runs/{}/cancel'
gh api -X GET "/repos/$OWNER/$REPOSITORY/actions/runs?per_page=3000" | jq '.workflow_runs[1:] | .[].id' | xargs -I{} sh -c 'echo {} && gh api --silent -X DELETE /repos/$OWNER/$REPOSITORY/actions/runs/{}'
