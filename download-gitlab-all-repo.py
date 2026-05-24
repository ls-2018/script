#!/usr/bin/env python3
import os,sys

import requests

gitlab_address = 'gitlab.datacanvas.com'

project_dir_root = os.getcwd()

project_set = set()


def pull_git_project():
    for index in range(100):
        url = "https://%s/api/v4/projects?private_token=%s&per_page=100&page=%d&order_by=name" % (
            gitlab_address, sys.argv[1], index
        )
        res = requests.get(url).json()
        if len(res) == 0:
            break
        for thisProject in res:
            thisProjectPath = os.path.join(project_dir_root, thisProject['path_with_namespace'])
            project_set.add((thisProject['http_url_to_repo'], thisProject['ssh_url_to_repo'], thisProjectPath))

    for item in project_set:
        projectPath = item[2]
        addr = item[0]
        repo = item[1]
        print()
        print(addr)
        os.makedirs(projectPath, exist_ok=True)
        cmd = f"git clone {repo} {projectPath} "
        if len(os.listdir(projectPath)) > 0:
            print('skip, due to len(files)>0')
        else:
            os.system(cmd)


if __name__ == '__main__':
    pull_git_project()
