#!/usr/bin/env python3
import argparse
import json
import os
import sys

import pexpect
import pyotp


def get_datacenter_config(center):
    print("-->", center)
    with open("/Volumes/Tf/aps/online-secret.json", 'r', encoding="utf-8") as f:
        data = json.load(f)
    return (
        data[center]["proxy"],
        data[center]["proxy"].split(":")[0],
        data[center]["user"],
        data[center]["password"],
        data[center]["otp"],
        data[center]["cluster"],
        data[center]["kubeconfig"]
    )


def login_teleport(center):
    PROXY, PROXY_NO_port, USER, PASSWORD, OTP_KEY, CLUSTER_NAME, KUBECONFIG_PATH = get_datacenter_config(center)

    cmd = f"tsh login --proxy={PROXY} --auth=local --user={USER} {PROXY_NO_port}"
    print(cmd)
    try:
        os.environ["KUBECONFIG"] = KUBECONFIG_PATH

        # 启动登录进程
        child = pexpect.spawn(cmd)
        child.logfile = sys.stdout.buffer

        # 等待密码提示并输入密码
        index = child.expect([
            "Logged in as",
            "Enter password.*:",
        ], timeout=30)
        if index == 1:
            child.sendline(PASSWORD)
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
            totp = pyotp.TOTP(OTP_KEY, interval=30)
            otp_code = totp.now()
            print(f"\n生成的 OTP 码: {otp_code}")
            child.sendline(otp_code)
            print("\nOTP 码已输入...")

            # 等待登录结果
            index = child.expect(['Logged in as', USER], timeout=30)
        if index == 0:
            child.sendline(f'set KUBECONFIG={KUBECONFIG_PATH}')
            get_kube_access(CLUSTER_NAME)
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


def get_kube_access(cluster_name):
    try:
        print("\n正在获取 Kubernetes 访问权限...")
        # 列出可用的 Kubernetes 集群
        child = pexpect.spawn('tsh kube ls')
        child.logfile = sys.stdout.buffer
        child.expect(pexpect.EOF, timeout=30)

        # 获取指定集群的访问权限
        print(f"\n正在登录到集群: {cluster_name}")
        child = pexpect.spawn(f'tsh kube login {cluster_name}')
        child.logfile = sys.stdout.buffer
        child.expect(pexpect.EOF, timeout=30)

        print("\n您现在可以使用 tsh 和 kubectl 命令了")
    except Exception as e:
        print(f"\n获取 Kubernetes 访问权限时出错: {str(e)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='示例脚本 - 展示命令行参数处理')
    parser.add_argument('-c', '--center', help='请输入中心ID')
    args = parser.parse_args()
    print(args.center)
    print("开始登录 Teleport...")
    login_teleport(args.center)

