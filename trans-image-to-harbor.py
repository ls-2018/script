#!/usr/bin/env python3
import os
import sys
raw_image = sys.argv[1]
image_tag = raw_image.split('/')[-1]
os.system(f"docker pull {raw_image}")
os.system(f"docker tag {raw_image} harbor.ls.com/acejilam/{image_tag}")
os.system(f"docker push harbor.ls.com/acejilam/{image_tag}")
os.system(f"docker rmi harbor.ls.com/acejilam/{image_tag}")
os.system("docker image prune -f")