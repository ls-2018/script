#!/usr/bin/env python3
import copy
import os
import shlex
import sys

from trans_image_name import trans_image

docker_bin = ''
for item in ['/opt/homebrew/bin/docker', '/usr/local/bin/docker', '/usr/bin/docker']:
    if os.path.exists(item):
        docker_bin = item
        break

cmds = [docker_bin]
if len(sys.argv) == 1:
    os.system(docker_bin)
    sys.exit(0)

cmds_bak = copy.deepcopy(sys.argv)
cmds_bak[0] = docker_bin
if sys.argv[1] in ['run', 'pull', 'rmi', 'rm', 'tag', 'save']:
    print("➡️ ➡️ ➡️ ➡️", cmds_bak, flush=True)
    os.system(" ".join(shlex.quote(x) for x in cmds_bak))
    sys.exit(0)

for item in sys.argv[1:]:
    cmds.append(trans_image(item))
os.system(" ".join(shlex.quote(x) for x in cmds))


def run_realtime_raw(cmd):
    import subprocess, sys

    p = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        bufsize=0
    )

    while True:
        chunk = p.stdout.read(1)
        if not chunk:
            break
        sys.stdout.write(chunk.decode(errors="ignore"))
        sys.stdout.flush()

    return p.wait()
