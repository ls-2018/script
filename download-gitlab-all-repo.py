#!/usr/bin/env python3
import os
import requests

gitlab_address = 'gitlab.datacanvas.com'
gitlab_token = 'FtSVkf-v_nGqCVQdQVzE'
project_dir_root = ''


def pull_git_project():
    for index in range(100):
        url = "https://%s/api/v4/projects?private_token=%s&per_page=100&page=%d&order_by=name" % (
            gitlab_address, gitlab_token, index)

        res = requests.get(url).json()

        if len(res) == 0:
            break
        for thisProject in res:
            thisProjectPath = project_dir_root + \
                thisProject['path_with_namespace']
            print(thisProjectPath)
            if len(thisProject.get('forked_from_project',{}))>0:
                continue
            if '/' in thisProjectPath:
                m = '/'.join(thisProjectPath.split('/')[:-1])
                cmd = f"mkdir -p {m} && cd {m} && git clone git@{gitlab_address}:{thisProjectPath}.git && cd -"
                os.system(cmd)
            else:
                cmd = f"git clone git@{gitlab_address}:{thisProjectPath}.git"
                os.system(cmd)


if __name__ == '__main__':
    pull_git_project()
