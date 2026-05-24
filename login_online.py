#!/usr/bin/env python3
import argparse
import json
import os
import subprocess
from collections import defaultdict

import pexpect
import pyotp

cluster_set = defaultdict(list)
home = os.path.expanduser("~")
os.system(f'rm -rf {home}/.kube/online*')
os.system(f'pkill -9 Lens')


class Login:
    def __init__(self, center, proxy, user, password, otp, cmd):
        self.cmd = cmd
        self.center = center
        self.proxy = proxy
        self.port = proxy.split(":")[0]
        self.user = user
        self.password = password
        self.otp = otp
        os.system('echo "" > /tmp/{center}.log')
        self.f = open(f'/tmp/{center}.log', 'ab+')
        self.f.truncate(0)

    def get_clusters(self):
        cs = set()
        for item in subprocess.getoutput(f'cat {self.f.name}').split('--------')[-1].split('\n'):
            if item.strip() != '':
                cs.add(item.strip().split(' ')[0].strip())
        return cs

    def get_kube_access(self):
        try:
            # 列出可用的 Kubernetes 集群
            child = pexpect.spawn('tsh kube ls')
            child.logfile = self.f
            child.expect(pexpect.EOF, timeout=30)
            self.f.flush()
            # 获取指定集群的访问权限
            for cluster in self.get_clusters():
                os.environ["KUBECONFIG"] = os.path.join(home, ".kube", f"online-{self.center}-{cluster}.config")
                self.print(f"\n正在登录到集群: {cluster}")
                child = pexpect.spawn(f'tsh kube login {cluster}')
                child.logfile = self.f
                child.expect(pexpect.EOF, timeout=30)
                with open(f'/tmp/pre-run.sh', 'w', encoding='utf8') as f:
                    f.truncate(0)
                    f.write(f'''
ok() {{
    printf "\033[32m✅ %s\033[0m\n" "$*"
}}
ok center:{self.center} cluster:{cluster}
''')
                os.system('bash /tmp/pre-run.sh')
                if self.cmd != "":
                    with open(f'/tmp/pre-run.sh', 'w', encoding='utf8') as f:
                        f.truncate(0)
                        f.write(f'''
export KUBECONFIG={os.path.join(home, ".kube", f"online-{self.center}-{cluster}.config")}                    
{self.cmd}  
echo ''
''')
                    os.system('bash /tmp/pre-run.sh')
        except Exception as e:
            print(f"\n获取 Kubernetes 访问权限时出错: {str(e)}")

        self.f.flush()
        self.f.close()

    def print(self, arg):
        self.f.write(arg.encode('utf-8'))
        self.f.flush()

    def login_teleport(self):
        cmd = f"tsh login --proxy={self.proxy} --auth=local --user={self.user} {self.port}"
        self.print(cmd)
        try:
            # 启动登录进程
            child = pexpect.spawn(cmd)
            child.logfile = self.f

            # 等待密码提示并输入密码
            index = child.expect([
                "Logged in as",
                "Enter password.*:",
            ], timeout=30)
            if index == 1:
                child.sendline(self.password)
                self.print("\n密码已输入...")

                # 等待 TOTP 提示并输入
                patterns = [
                    "Tap any security key or enter a code from a OTP device:",
                    "Tap any security key.*:",
                    "Enter your OTP code:",
                    "Enter OTP code:",
                    "Tap any security key",
                    "Enter an OTP code from a device:",
                ]
                child.expect(patterns, timeout=60)
                self.print("\n检测到 OTP 提示...")

                # 生成并输入 TOTP 码
                totp = pyotp.TOTP(self.otp, interval=30)
                otp_code = totp.now()
                self.print(f"\n生成的 OTP 码: {otp_code}")
                child.sendline(otp_code)
                self.print("\nOTP 码已输入...")
                # 等待登录结果
                index = child.expect(['Logged in as', self.user], timeout=30)

            if index == 0:
                self.print('登陆成功')
            else:
                self.print("登录失败")


        except pexpect.ExceptionPexpect as e:
            self.print(f"\n发生错误: {str(e)}")
            return False
        except Exception as e:
            self.print(f"\n未预期的错误: {str(e)}")
            return False
        finally:
            try:
                child.close()
            except:
                pass


def login():
    parser = argparse.ArgumentParser(description='示例脚本 - 展示命令行参数处理')
    parser.add_argument(
        '-c', '--cmd', help='command to execute',
        default='',
        # default="kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{\" \"}{end}'"
    )
    args = parser.parse_args()
    with open("/Volumes/Tf/aps/online-secret.json", 'r', encoding="utf-8") as f:
        data = json.load(f)
    for center, conf in data.items():
        l = Login(
            center=center,
            proxy=conf["proxy"],
            user=conf["user"],
            password=conf["password"],
            otp=conf["otp"],
            cmd=args.cmd,
        )
        l.login_teleport()
        l.get_kube_access()


if __name__ == "__main__":
    login()
