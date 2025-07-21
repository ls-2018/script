#! /usr/bin/env python3
import os
import subprocess

files = [
    "site/content/zh-CN/docs/tasks/manage/rbac.md",
    "site/content/zh-CN/docs/tasks/manage/setup_multikueue.md",
    "site/content/zh-CN/docs/tasks/manage/setup_object_retention_policy.md",
    "site/content/zh-CN/docs/tasks/manage/setup_wait_for_pods_ready.md",
    "site/content/zh-CN/docs/tasks/run/_index.md",
    "site/content/zh-CN/docs/tasks/run/appwrappers.md",
    "site/content/zh-CN/docs/tasks/run/deployment.md",
    "site/content/zh-CN/docs/tasks/run/external_workloads/_index.md",
    "site/content/zh-CN/docs/tasks/run/external_workloads/argo_workflow.md",
    "site/content/zh-CN/docs/tasks/run/external_workloads/flux_miniclusters.md",
    "site/content/zh-CN/docs/tasks/run/external_workloads/tektoncd.md",
    "site/content/zh-CN/docs/tasks/run/external_workloads/wrapped_custom_workload.md",
    "site/content/zh-CN/docs/tasks/run/jobs.md",
    "site/content/zh-CN/docs/tasks/run/jobsets.md",
    "site/content/zh-CN/docs/tasks/run/kubeflow/_index.md",
    "site/content/zh-CN/docs/tasks/run/kubeflow/jaxjobs.md",
    "site/content/zh-CN/docs/tasks/run/kubeflow/mpijobs.md",
    "site/content/zh-CN/docs/tasks/run/kubeflow/paddlejobs.md",
    "site/content/zh-CN/docs/tasks/run/kubeflow/pytorchjobs.md",
    "site/content/zh-CN/docs/tasks/run/kubeflow/tfjobs.md",
    "site/content/zh-CN/docs/tasks/run/kubeflow/xgboostjobs.md",
    "site/content/zh-CN/docs/tasks/run/leaderworkerset.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/_index.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/appwrapper.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/deployment.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/job.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/jobsets.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/kubeflow.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/kuberay.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/mpijob.md",
    "site/content/zh-CN/docs/tasks/run/multikueue/plain_pods.md",
    "site/content/zh-CN/docs/tasks/run/plain_pods.md",
    "site/content/zh-CN/docs/tasks/run/python_jobs.md",
    "site/content/zh-CN/docs/tasks/run/rayclusters.md",
    "site/content/zh-CN/docs/tasks/run/rayjobs.md",
    "site/content/zh-CN/docs/tasks/run/run_cronjobs.md",
    "site/content/zh-CN/docs/tasks/run/statefulset.md",
]

context = '''#### What type of PR is this?

/kind documentation
/area localization
/language zh

#### What this PR does / why we need it:

#### Which issue(s) this PR fixes:
[zh] Sync %s to Chinese.

#### Special notes for your reviewer:

#### Does this PR introduce a user-facing change?
 
```release-note
NONE
```
'''

cmd = '''
export http_proxy=http://hproxy.it.zetyun.cn:1080; export https_proxy=http://hproxy.it.zetyun.cn:1080;
rm -rf /Users/acejilam/Desktop/asdfg
cp -rf /Users/acejilam/Desktop/kueue /Users/acejilam/Desktop/asdfg
cd /Users/acejilam/Desktop/asdfg

git add . 
git reset --hard $((git show-ref --head --hash=8 2>/dev/null || echo 00000000) | head -n1)
git status

cp -rf /Users/acejilam/Desktop/kueue/%s /Users/acejilam/Desktop/asdfg/%s
git checkout -b w_doc_%d
git add .
git status
git commit -s -m "cn doc"
git push --set-upstream origin w_doc_%d --force

gh repo set-default kubernetes-sigs/kueue

'''

index = 21
for i, file in enumerate(files):
    indexer = index + i

    c = cmd % (file, file, indexer, indexer)
    print(c)
    subprocess.run(c, stdout=subprocess.PIPE, shell=True, text=True)
    with open('/tmp/a.txt', 'w') as f:
        f.write(context % file)
    os.system(f"cd /Users/acejilam/Desktop/asdfg/ && gh pr create --title '[zh] Sync {file} to Chinese' --body-file /tmp/a.txt")
    print(file)
