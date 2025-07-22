import os
import re
import shutil
import subprocess
import time

base_dir = '/Users/acejilam/Desktop/kueue_test'

replace_list_need_confirm = [
    (' pod ', ' Pod '),
    (' kueue ', ' Kueue '),
    ('clusterQueue', 'ClusterQueue'),
]
replace_list_not_confirm = [
    ('例如1s', '例如 1s'),
    (')	 -', ') -'),
    (' pod ', ' Pod '),
    (' kueue ', ' Kueue '),
    ('识别您命名空间中的队列', '识别命名空间中的队列'),
    ('clusterQueue', 'ClusterQueue'),
    ('用于 API 服务器身份验证的 Bearer 令牌', "用于 API 服务器身份验证的持有者令牌"),
    ('其中之一', "可选值为"),
    (
        '(json, yaml, name, go-template, go-template-file, template, templatefile, jsonpath, jsonpath-as-json, jsonpath-file)',
        'json、yaml、name、go-template、go-template-file、template、templatefile、jsonpath、jsonpath-as-json、jsonpath-file'
    )
]

ref_list = [
    ('## 概要', 'synopsis'),
    ('## 选项', 'options'),
    ('## 从父命令继承的选项', 'options-inherited-from-parent-commands'),
    ('## 示例', 'examples'),
    ('## 0. 识别您命名空间中的可用队列', '0 identify-the-queues-available-in-your-namespace'),
    ('## 另请参阅', 'see-also'),
    ('## 开始之前', 'before-you-begin'),
    ('## 在开始之前', 'before-you-begin'),
    ('## 1. 定义作业', '1 define-the-job'),
    ('## 2. 运行 CronJob', '2 run-the-cronjob'),
    ('## XGBoostJob 定义', 'xgboostjob-definition'),
    ('### a. 队列选择', 'a Queue selection'),
    ('### b. 可选地在 XGBoostJobs 中设置 Suspend 字段', 'b Optionally set Suspend field in XGBoostJobs'),
    ('## XGBoostJob 示例', 'Sample XGBoostJob'),
    ('## 运行 Jobsets 示例', 'Run Jobsets example'),
    ('## 使用 LeaderWorkerSets 作为自定义工作负载的示例', 'Example using LeaderWorkerSets as the Custom Workload'),
    ('### 启用 JobManagedBy 的集群', 'Cluster with JobManagedBy enabled'),
    ('### 未启用 JobManagedBy 的集群', 'Cluster with JobManagedBy disabled'),
    ('## PaddleJob 定义', 'PaddleJob definition'),
    ('### b. 可选地在 PaddleJobs 中设置 Suspend 字段', 'b Optionally set Suspend field in PaddleJobs'),
    ('## PaddleJob 示例', 'Sample PaddleJob'),
    ('### c. 扩展', 'c Scaling'),
    ('### c. 限制', 'c Limitations'),
    ('### b. 可选地在 MPIJobs 中设置 Suspend 字段', 'b Optionally set Suspend field in MPIJobs'),
    ('## MPIJob 示例', 'Sample MPIJob'),
    ('## MultiKueue 集成', 'MultiKueue integration'),
    ('## RayJob 定义', 'RayJob definition'),
    ('## JobSet 定义', 'JobSet definition'),
    ('### c. 作业优先级', 'c Jobs prioritisation'),
    ('## MiniCluster 定义', 'MiniCluster definition'),
    ('## 限制', 'Limitations'),
    ('## 运行一个由 Kueue 承认的 LeaderWorkerSet', 'Running a LeaderWorkerSet admitted by Kueue'),
    ('### c. 缩放', 'c Scaling'),
    ('## JAXJob 定义', 'JAXJob definition'),
    ('### b. 可选地在 JAXJobs 中设置 Suspend 字段', 'b Optionally set Suspend field in JAXJobs'),
    ('## JAXJob 示例', 'Sample JAXJob'),
    ('### 集群上的安装', 'Installation on the Clusters'),
    ('## Multikueue', 'Multikueue'),
    ('### 基于内置框架的集成', 'Integrations based on built-in frameworks'),
    ('## MPI Operator 定义', 'MPI Operator definition'),
    ('## MiniCluster 示例', 'Sample MiniCluster'),
    ('## Tekton 背景', 'Tekton Background'),
    ('### Tekton 定义', 'Tekton Defintions'),
    ('## a. 目标为单个 LocalQueue', 'a Targeting a single LocalQueue'),
    ('## 运行被 Kueue 调度的 StatefulSet', 'Running a StatefulSet admitted by Kueue'),
    ('### b. 配置资源需求', 'b Configure the resource needs'),
    ('### [AppWrapper](https://project-codeflare.github.io/appwrapper/) 集成', 'AppWrapper Integration'),
    ('### [Trainer](https://github.com/kubeflow/trainer) 集成', 'Trainer Integration'),
    ('### [MPI Operator](https://github.com/kubeflow/mpi-operator) 集成', 'MPI Operator Integration'),
    ('### 终止', 'Termination'),
    ('### 功能限制', ' Feature limitations'),
    ('### d. 限制', 'd Limitations'),
    ('## 运行一组需要被 Kueue 管理的 Pod', 'Running a group of Pods to be admitted together'),
    ('## 运行一个被 Kueue 管理的 Pod', 'Running a single Pod admitted by Kueue'),
    ('## RayCluster 定义', 'RayCluster definition'),
    ('### c. 扩缩容', 'c Scaling'),
    ('## 运行 Kueue 管理的部署', 'Running a Deployment admitted by Kueue'),
    ('## 1. 定义 Job', '1 Define the job'),
    ('## 2. 运行 Job', '2 run the job'),
    ('## TFJob 定义', 'TFJob definition'),
    ('## 部分承认', 'partial-admission'),
    ('## TFJob 示例', 'Sample TFJob'),
    ('### c. "managed" 标签', 'c managed label'),
    ('## 与 MPI Operator 协同工作', 'Working alongside MPI Operator'),
    ('## 0. 识别命名空间中的队列', '0-identify-the-queues-available-in-your-namespace'),
    ('## 3. (可选) 监控工作负载状态', '3-optional-monitor-the-status-of-the-workload'),
    ('### b. 可选地在 TFJobs 中设置 Suspend 字段', 'b Optionally set Suspend field in TFJobs'),
]


def replace_confirm(data):
    ds = data.split('\n')
    for line in ds:
        raw_line = line
        for item in replace_list_need_confirm:
            if item[0] in line:
                print(line)
                if input("---->", ).lower() != 'n':
                    line = line.replace(item[0], item[1])
        data = data.replace(raw_line, line)
    return data


def replace(data):
    ds = data.split('\n')
    for line in ds:
        raw_line = line
        for item in replace_list_not_confirm:
            if item[0] in line:
                print(line)
                line = line.replace(item[0], item[1])
        data = data.replace(raw_line, line)
    return data


def h1(file, project_dir):
    with open(file, 'r', encoding='utf8') as f:
        data = f.read()
    print(file)
    for line in data.split('\n'):
        raw_line = line

        for item in ref_list:
            new_ref = f'{{#{item[1].lower().strip().replace(' ', '-')}}}'
            if item[0] in line:
                line = line.replace(item[0], f"{item[0]} {new_ref}")
            if f"{item[0]} {new_ref} {new_ref} {new_ref}" in line:
                line = line.replace(f"{item[0]} {new_ref} {new_ref} {new_ref}", f"{item[0]} {new_ref}")
            if f"{item[0]} {new_ref} {new_ref}" in line:
                line = line.replace(f"{item[0]} {new_ref} {new_ref}", f"{item[0]} {new_ref}")

        cmd = f'cd {project_dir} && git diff {file[len(project_dir) + 1:]} |grep "{line.strip()}" -C 5  '
        if line.startswith('### ') and '{#' not in line:
            print("⚠️", line)
            print(cmd)
            os.system(cmd)

        if line.startswith('## ') and '{#' not in line:
            print("⚠️", line)
            print(cmd)
            os.system(cmd)
        if line.startswith('##') and len(re.findall('\{#', line)) > 1:
            print("⚠️", line)
        data = data.replace(raw_line, line)
    with open(file, 'w', encoding='utf8') as f:
        f.write(data)


def h2(file):
    with open(file, 'r', encoding='utf8') as f:
        data = f.read()
    for line in data.split('\n'):
        res = re.findall(r'[\u4e00-\u9fff][a-zA-Z]', line)
        if len(res) != 0:
            raw_line = line
            print("✈️✈️✈️✈️✈️✈️✈️✈️✈️", res, line)
            for xx in set(res):
                i1, i2 = list(xx)
                line = line.replace(xx, ''.join([i1, ' ', i2]))
            data = data.replace(raw_line, line)

        res = re.findall(r'[a-zA-Z][\u4e00-\u9fff]', line)
        if len(res) != 0:
            raw_line = line
            print("✈️✈️✈️✈️✈️✈️✈️✈️✈️", res, line, )
            for xx in set(res):
                i1, i2 = list(xx)
                line = line.replace(xx, ''.join([i1, ' ', i2]))
            data = data.replace(raw_line, line)

    _data = replace(data)
    with open(file, 'w', encoding='utf8') as f:
        f.write(_data)


shutil.rmtree(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data'), ignore_errors=True)
os.makedirs(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data'), exist_ok=True)


def link(f):
    l_f = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data', str(time.time_ns()) + '.md')
    os.system(f'ln -s {f} {l_f}')


def walk():
    for number in os.listdir(base_dir):
        if not number.isdigit():
            continue
        print(number)
        out = subprocess.getoutput(f"cd {os.path.join(base_dir, number)} && git status --porcelain")
        for line in out.splitlines():
            f = os.path.join(base_dir, number, line.split(' ')[-1])
            # os.system(f"code {f}")
            link(f)
            h2(f)
            h1(f, os.path.join(base_dir, number))


if __name__ == '__main__':
    walk()
