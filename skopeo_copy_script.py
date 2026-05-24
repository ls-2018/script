#!/usr/bin/env python3
import json
import os.path
import shutil
import sys
from tencent import public


try:
    fix_sync_path = os.path.join(os.path.dirname(os.readlink(os.path.abspath(__file__))), 'fixed-tasks.json')
except OSError:
    fix_sync_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fixed-tasks.json')

with open(fix_sync_path, 'r', encoding='utf8') as f:
    fix_data = json.loads(f.read())

try:
    sync_path = os.path.join(os.path.dirname(os.readlink(os.path.abspath(__file__))), 'random-tasks.json')
except OSError:
    sync_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'random-tasks.json')

with open(sync_path, 'r', encoding='utf8') as f:
    random_data = json.loads(f.read())

if __name__ == '__main__':
    repo_tag = sys.argv[1].strip()
    if len(repo_tag.split('/')) < 3 and '.' not in repo_tag.split('/')[0]:
        print(repo_tag)
        raise Exception('must have group/user/repo')

    repo, tag = '', ''
    if len(repo_tag.split(':')) == 2:
        repo, tag = repo_tag.split(':')
    else:
        repo, tag = repo_tag, "latest"

    s_img = f'{repo}:{tag}'
    fixed = False
    tmp_path = ' '
    if repo in fix_data:
        fixed = True
        ds = set(fix_data[repo])
        ds.add(tag)
        fix_data[repo] = list(ds)

    else:
        if repo in random_data:
            ds = set(random_data[repo])
            ds.add(tag)
            random_data[repo] = list(ds)
        else:
            random_data[repo] = [tag]

    with (open(sync_path + '.bak', 'w', encoding='utf8')) as f:
        f.write(json.dumps(random_data, indent=4, ensure_ascii=False))
    with (open(fix_sync_path + '.bak', 'w', encoding='utf8')) as f:
        f.write(json.dumps(fix_data, indent=4, ensure_ascii=False))

    from trans_image import trans_image

    with open('/tmp/sc.sh', 'w', encoding='utf8') as f:
        cmd = f'''
source ~/script/.customer_script.sh
rm -rf /tmp/skopeo_copy_success
skopeo_copy {s_img} {trans_image(s_img, random_path=sync_path + '.bak', fixed_path=fix_sync_path + '.bak')}
set -v

cd ~/k8s/utils
pwd

go install ./cmd/...   
trans-image-name {s_img}
trans-image-name check
'''
        f.write(cmd)
        print(f"""skopeo_copy {s_img} {trans_image(s_img, random_path=sync_path + '.bak')}""")
    os.system('bash /tmp/sc.sh')

    if os.path.exists('/tmp/skopeo_copy_success'):
        shutil.copy2(fix_sync_path + '.bak', fix_sync_path)
        shutil.copy2(sync_path + '.bak', sync_path)
    public()