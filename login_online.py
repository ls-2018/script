#!/usr/bin/env python3
import json
import os
import sys
from collections import defaultdict

import pexpect
import pyotp

cluster_set = defaultdict(list)
home = os.path.expanduser("~")


class Login:
    def __init__(self, center, proxy, user, password, otp):
        self.center = center
        self.proxy = proxy
        self.port = proxy.split(":")[0]
        self.user = user
        self.password = password
        self.otp = otp
        self.f = open(f'/tmp/{center}.log', 'wb')

    def get_kube_access(self, ):
        try:
            # os.environ["KUBECONFIG"] = os.path.join(home, ".kube", f"{self.center}-{cluster}.config")

            # 列出可用的 Kubernetes 集群
            child = pexpect.spawn('tsh kube ls')
            child.logfile = self.f
            child.expect(pexpect.EOF, timeout=30)
            self.f.flush()
            # 获取指定集群的访问权限
            # print(f"\n正在登录到集群: {cluster_name}")
            # child = pexpect.spawn(f'tsh kube login {cluster_name}')
            # child.logfile = self.f
            # child.expect(pexpect.EOF, timeout=30)

            print("\n您现在可以使用 tsh 和 kubectl 命令了")
        except Exception as e:
            print(f"\n获取 Kubernetes 访问权限时出错: {str(e)}")
        self.f.close()

    def login_teleport(self, ):

        cmd = f"tsh login --proxy={self.proxy} --auth=local --user={self.user} {self.port}"
        self.f.write((cmd + '\n').encode('utf-8'))
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
                print("\n密码已输入...")

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
                print("\n检测到 OTP 提示...")

                # 生成并输入 TOTP 码
                totp = pyotp.TOTP(self.otp, interval=30)
                otp_code = totp.now()
                print(f"\n生成的 OTP 码: {otp_code}")
                child.sendline(otp_code)
                print("\nOTP 码已输入...")

                # 等待登录结果
                index = child.expect(['Logged in as', self.user], timeout=30)
                self.get_kube_access()
            if index == 0:
                # child.sendline(f'export KUBECONFIG={KUBECONFIG_PATH}')
                # with open('/tmp/k8s_config.sh', 'w', encoding="utf-8") as f:
                #     f.write(f"export KUBECONFIG={KUBECONFIG_PATH}")
                self.get_kube_access()
            else:
                print("登录失败")


        except pexpect.ExceptionPexpect as e:
            print(f"\n发生错误: {str(e)}")
            return False
        except Exception as e:
            print(f"\n未预期的错误: {str(e)}")
            return False
        finally:
            try:
                child.close()
            except:
                pass
        return self


def login():
    with open("/Volumes/Tf/aps/online-secret.json", 'r', encoding="utf-8") as f:
        data = json.load(f)
    for key in data.keys():
        print("--->", key)

    for center, conf in data.items():
        Login(
            center=center,
            proxy=conf["proxy"],
            user=conf["user"],
            password=conf["password"],
            otp=conf["otp"],
        ).login_teleport()


if __name__ == "__main__":
    login()
