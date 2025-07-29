#! /usr/bin/env python3
import os
import re
import shutil
import subprocess
import time

base_dir = '/Users/acejilam/Desktop/kueue_test'

replace_list_need_confirm = [
    (' `pod` ', ' `Pod` '),
    (' pod ', ' Pod '),
    (' kueue ', ' Kueue '),
    ('clusterQueue', 'ClusterQueue'),
    ('](/docs', '](/zh-CN/docs'),
    ('安装]', '安装文档]'),
]
replace_list_not_confirm = [
    ('例如1s', '例如 1s'),
    (')	 -', ') -'),
    ('识别您命名空间中的队列', '识别命名空间中的队列'),
    ('上下文名称', '上下文的名称'),
    ('镜像副本不会设置该字段', '镜像副本未设置此字段'),
    ('集群名称', '集群的名称'),
    ('{{% alert title="Note" color="primary" %}}', '{{% alert title="注意" color="primary" %}}'),
    ('则使用用于联系服务器的主机名', '则使用联系服务器所用的主机名'),
    ('您', '你'),
    ('用于 API 服务器身份验证的 Bearer 令牌', "用于 API 服务器身份验证的持有者令牌"),
    ('用于 API 服务器身份验证的持有者令牌', 'API 服务器身份验证所用的持有者令牌'),
    ('要使用的 kubeconfig 用户名', '要使用的 kubeconfig 用户的名称'),
    ('此标志可以重复指定多个组', '此标志可以重复使用，以指定多个组'),
    ('则选择退出对所有服务器请求的响应压缩', '则取消对所有服务器请求的响应压缩'),
    ('这将使您的', '这将使你的'),
    ('在开始之前', '开始之前'),
    ('clusterQueue', 'ClusterQueue'),
    ('其中之一', "可选值为"),
    (
        '(json, yaml, name, go-template, go-template-file, template, templatefile, jsonpath, jsonpath-as-json, jsonpath-file)',
        'json、yaml、name、go-template、go-template-file、template、templatefile、jsonpath、jsonpath-as-json、jsonpath-file'
    )
]

ref_list = [
    ('## 概要', 'synopsis'),
    ('### 重新入队策略', 'Requeuing Strategy'),
    ('### 1. 准备工作', '1 Preparation'),
    ('#### 运行作业', 'Run the jobs'),
    ('### 2. 在默认配置下诱发死锁（可选）', '2 Induce a deadlock under the default configuration optional'),
    ('## 设置保留策略', 'Set up a retention policy'),
    ('## AppWrapper 定义', 'AppWrapper definition'),
    ('## 启用 waitForPodsReady', 'Enabling waitForPodsReady'),
    ('#### 启用 waitForPodsReady', 'Enable waitForPodsReady'),
    ('### 3. 启用 waitForPodsReady 后运行', '3 Run with waitForPodsReady enabled'),
    ('## 局限性', 'Drawbacks'),
    ('## 3. (可选)监控工作负载状态', 'Drawbacks'),
    ('## 前置条件', 'Prerequisites'),
    ('## 包含 Deployment 的 AppWrapper 示例', 'Example AppWrapper containing a Deployment'),
    ('## 包含 PyTorchJob 的 AppWrapper 示例', 'Example AppWrapper containing a PyTorchJob'),
    ('## 在配额管理中排除任意资源', 'Exclude arbitrary resources in the quota management'),
    ('### 1. 创建 [ClusterQueue](/docs/concepts/cluster_queue)', '1 create clusterqueue'),
    ('### 1. 创建 [ClusterQueue](/zh-CN/docs/concepts/cluster_queue)', '1 create clusterqueue'),
    ('### 2. 创建 [ResourceFlavor](/zh-CN/docs/concepts/cluster_queue#resourceflavor-object)',
     '2 create ResourceFlavor'),
    ('### 2. 创建 [ResourceFlavor](/docs/concepts/cluster_queue#resourceflavor-object)', '2 create ResourceFlavor'),
    ('### 3. 创建 [LocalQueues](/docs/concepts/local_queue)', '3 create LocalQueues'),
    ('### 3. 创建 [LocalQueues](/zh-CN/docs/concepts/local_queue)', '3 create LocalQueues'),
    ('### Kueue 配置', 'Kueue Configuration'),
    ('### Workload 保留策略', 'Workload Retention Policy'),
    ('## 在你开始之前', 'Before you begin'),
    ('### 场景 A：成功完成的 Workload', 'Scenario A Successfully finished Workload'),
    ('## 单一 ClusterQueue 和单一 ResourceFlavor 设置', 'Single ClusterQueue and single ResourceFlavor setup'),
    ('## 多 ResourceFlavor 设置', 'Multiple ResourceFlavors setup'),
    ('### 1. 创建 ResourceFlavors', '1 Create ResourceFlavors'),
    ('### 2. 创建引用风味的 ClusterQueue', '2 Create a ClusterQueue referencing the flavors'),
    ('## 多 ClusterQueue 与借用 cohort', 'Multiple ClusterQueues and borrowing cohorts'),
    ('## 多 ClusterQueue 的专用与回退风味', 'Multiple ClusterQueue with dedicated and fallback flavors'),
    ('## 配额管理的资源转换', 'Transform resources for quota management'),
    ('## 在工作集群中', 'In the Worker Cluster'),
    ('### MultiKueue 专用 Kubeconfig', 'MultiKueue Specific Kubeconfig'),
    ('### Kubeflow 安装', 'Kubeflow Installation'),
    ('## 在管理集群中', 'In the Manager Cluster'),
    ('### CRD 安装', 'CRDs installation'),
    ('### 创建工作集群的 Kubeconfig Secret', 'Create workers Kubeconfig secret'),
    ('### 创建示例配置', 'Create a sample setup'),
    ('## 选项', 'options'),
    ('## 0. 识别你命名空间中的可用队列', '0. Identify the queues available in your namespace'),
    ('## （可选）结合 Open Cluster Management 配置 MultiKueue', 'optional Setup MultiKueue with Open Cluster Management'),
    ('## 从父命令继承的选项', 'options-inherited-from-parent-commands'),
    ('## 示例', 'examples'),
    ('## 0. 识别您命名空间中的可用队列', '0 identify-the-queues-available-in-your-namespace'),
    ('## 另请参阅', 'see-also'),
    ('### 另请参阅', 'see-also'),
    ('## 开始之前', 'before-you-begin'),
    ('## 在开始之前', 'before-you-begin'),
    ('## 1. 定义作业', '1 define-the-job'),
    ('## 2. 运行 CronJob', '2 run-the-cronjob'),
    ('## XGBoostJob 定义', 'xgboostjob-definition'),
    ('### a. 队列选择', 'a Queue selection'),
    ('### b. 可选地在 XGBoostJobs 中设置 Suspend 字段', 'b Optionally set Suspend field in XGBoostJobs'),
    ('## XGBoostJob 示例', 'Sample XGBoostJob'),
    ('## 运行 Jobsets 示例', 'Run Jobsets example'),
    ('### MPI Operator 作业', 'MPI Operator Job'),
    ('## Kueue 在 Python 中', 'Kueue in Python'),
    ('### 与队列和作业交互', 'Interact with Queues and Jobs'),
    ('### Flux Operator 作业', 'Flux Operator Job'),
    ('## 使用 LeaderWorkerSets 作为自定义工作负载的示例', 'Example using LeaderWorkerSets as the Custom Workload'),
    ('### 启用 JobManagedBy 的集群', 'Cluster with JobManagedBy enabled'),
    ('### 未启用 JobManagedBy 的集群', 'Cluster with JobManagedBy disabled'),
    ('## PaddleJob 定义', 'PaddleJob definition'),
    ('### b. 可选地在 PaddleJobs 中设置 Suspend 字段', 'b Optionally set Suspend field in PaddleJobs'),
    ('## PaddleJob 示例', 'Sample PaddleJob'),
    ('### c. 扩展', 'c Scaling'),
    ('## PyTorchJob 定义', 'PyTorchJob definition'),
    ('### b. 可选地在 PyTorchJobs 中设置 Suspend 字段', 'b Optionally set Suspend field in PyTorchJobs'),
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
    ('## PyTorchJob 示例', 'Sample PyTorchJob'),
    ('### Tekton 定义', 'Tekton Definitions'),
    ('### 安装 Kueue', 'Install Kueue'),
    ('## a. 目标为单个 LocalQueue', 'a Targeting a single LocalQueue'),
    ('## 运行被 Kueue 调度的 StatefulSet', 'Running a StatefulSet admitted by Kueue'),
    ('### b. 配置资源需求', 'b Configure the resource needs'),
    ('### [AppWrapper](https://project-codeflare.github.io/appwrapper/) 集成', 'AppWrapper Integration'),
    ('### [Trainer](https://github.com/kubeflow/trainer) 集成', 'Trainer Integration'),
    ('### [MPI Operator](https://github.com/kubeflow/mpi-operator) 集成', 'MPI Operator Integration'),
    ('### 终止', 'Termination'),
    ('## 说明', 'Notes'),
    ('### 场景 B：通过 `waitForPodsReady` 驱逐的 Workload', 'Scenario B Evicted Workload via waitForPodsReady'),
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
                highlight_substring(line, item[0])
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
    data = replace_confirm(data)
    return data


def highlight_substring(text, substring, color_code="\033[91m"):  # 黄色
    reset_code = "\033[0m"
    print(text.replace(substring, f"{color_code}{substring}{reset_code}"))


def h1(file, project_dir):
    with open(file, 'r', encoding='utf8') as f:
        data = f.read()
    for line in data.split('\n'):
        raw_line = line
        for item in ref_list:
            new_ref = '{#' + item[1].lower().strip().replace(".", "").replace(' ', '-') + "}"
            if line.startswith(item[0]):
                line = line.replace(item[0], f"{item[0]} {new_ref}")
            if line.startswith(f"{item[0]} {new_ref} {new_ref} {new_ref}"):
                line = line.replace(f"{item[0]} {new_ref} {new_ref} {new_ref}", f"{item[0]} {new_ref}")
            if line.startswith(f"{item[0]} {new_ref} {new_ref}"):
                line = line.replace(f"{item[0]} {new_ref} {new_ref}", f"{item[0]} {new_ref}")
        data = data.replace(raw_line, line)
        cmd = f"cd {project_dir} && git diff {file[len(project_dir) + 1:]} |grep '{line.strip()}' -C 5  "
        if line.startswith('### ') and '{#' not in line:
            print("⚠️", line)
            print(cmd)
            os.system(cmd)

        if line.startswith('## ') and '{#' not in line:
            print("⚠️", line)
            print(cmd)
            os.system(cmd)
        if line.startswith('##') and len(re.findall(r'\{#', line)) > 1:
            print("⚠️", line)
    with open(file, 'w', encoding='utf8') as f:
        f.write(data)


def h2(file):
    data = ''
    with open(file, 'r', encoding='utf8') as f:
        data = f.read()

    for match_str in [
        (r'\u4e00-\u9fff [\u4e00-\u9fff]', ''),  # 文 [中
        (r'\) [\u4e00-\u9fff]', ''),
        (r'\] [\u4e00-\u9fff]', ''),
        (r'[\u4e00-\u9fff][a-zA-Z]', ' '),
        (r'[a-zA-Z][\u4e00-\u9fff]', ' ')
    ]:
        for line in data.split('\n'):
            res = re.findall(match_str[0], line)
            if len(res) != 0:
                raw_line = line
                print("✈️✈️✈️✈️✈️✈️✈️✈️✈️", res, line)
                for xx in set(res):
                    if len(list(xx)) == 3:
                        i1, _, i2 = list(xx)
                    else:
                        i1, i2 = list(xx)
                    line = line.replace(xx, match_str[1].join([i1, i2]))
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
