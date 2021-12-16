#	KubeSphere安装

----

#   已有Kubernetes环境

##  安装2.1.1版

### 前提条件

看这个官方文档 https://v2-1.docs.kubesphere.io/docs/zh-CN/installation/prerequisites/

+   Kubernetes 版本： 1.15.x ≤ K8s version ≤ 1.17.x；
+   Helm版本： 2.10.0 ≤ Helm Version ＜ 3.0.0，建议使用 Helm 2.16.2（不支持 helm 2.16.0 #6894），且已安装了 Tiller，参考 如何安装与配置 Helm （预计 3.0 支持 Helm v3）；
+   集群已有默认的存储类型（StorageClass），若还没有准备存储请参考 安装 OpenEBS 创建 LocalPV 存储类型 用作开发测试环境。
+   集群能够访问外网，若无外网请参考 在 Kubernetes 离线安装 KubeSphere。

这里需要注意的是Helm安装

下载地址 https://get.helm.sh/helm-v2.16.2-linux-amd64.tar.gz

```bash
$ mv helm /usr/local/bin/

$ helm version
Client: &version.Version{SemVer:"v2.16.9", GitCommit:"8ad7037828e5a0fca1009dabe290130da6368e39", GitTreeState:"clean"}
Error: could not find a ready tiller pod
# 暂时不用关注这个 Error

----

# 安装Tiller
$ kubectl create serviceaccount --namespace kube-system tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
$ helm_version=$(helm version --client | grep "Client" | cut -d '"' -f2)
$ helm init --upgrade --service-account tiller -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:${helm_version} --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts

# 验证 Tiller

$ kubectl get pods --namespace kube-system | grep tiller
tiller-deploy-6c45f9966d-vcmlk     1/1     Running   0          8s

# 删除 Tiller
$ kubectl delete deployment tiller-deploy --namespace kube-system
```

### 安装

文档地址 [在 Kubernetes 安装 KubeSphere](https://v2-1.docs.kubesphere.io/docs/zh-CN/installation/install-on-k8s/)

```bash
kubectl apply -f https://raw.githubusercontent.com/kubesphere/ks-installer/v2.1.1/kubesphere-minimal.yaml

# 说明：安装过程中若遇到问题，也可以通过以下日志命令来排查问题。
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

+   通过 kubectl get pod --all-namespaces 查看 KubeSphere 相关 namespace 下所有 Pod 状态是否为 Running。
+   确认 Pod 都正常运行后，可使用 IP:30880 访问 KubeSphere UI 界面，改IP通过 `kubectl edit svc xxxx`
+   默认的集群管理员账号为 admin/P@88w0rd。

![](../images/2021/12/20211216160513.png)


##  安装2.1.1版

文档地址 [在 Kubernetes 上最小化安装 KubeSphere](https://kubesphere.com.cn/docs/quick-start/minimal-kubesphere-on-k8s/)

### 前提条件

+   如需在 Kubernetes 上安装 KubeSphere 3.2.0，您的 Kubernetes 版本必须为：1.19.x、1.20.x、1.21.x 或 1.22.x（实验性支持）。
+   确保您的机器满足最低硬件要求：CPU > 1 核，内存 > 2 GB。
+   在安装之前，需要配置 Kubernetes 集群中的默认存储类型。

### 安装

确保您的机器满足安装的前提条件之后，可以按照以下步骤安装 KubeSphere。

执行以下命令开始安装：

```bash
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.2.0/kubesphere-installer.yaml
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.2.0/cluster-configuration.yaml
```

检查安装日志

```bash
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

使用 kubectl get pod --all-namespaces 查看所有 Pod 是否在 KubeSphere 的相关命名空间中正常运行。如果是，请通过以下命令检查控制台的端口（默认为 30880）：

```bash
kubectl get svc/ks-console -n kubesphere-system
```

确保在安全组中打开了端口 30880，并通过 NodePort (IP:30880) 使用默认帐户和密码 (admin/P@88w0rd) 访问 Web 控制台。

登录控制台后，您可以在系统组件中检查不同组件的状态。如果要使用相关服务，可能需要等待某些组件启动并运行。

+   访问任意机器的 30880端口
+   账号 ： admin
+   密码 ： P@88w0rd

解决etcd监控证书找不到问题


```bash
kubectl -n kubesphere-monitoring-system create secret generic kube-etcd-client-certs  --from-file=etcd-client-ca.crt=/etc/kubernetes/pki/etcd/ca.crt  --from-file=etcd-client.crt=/etc/kubernetes/pki/apiserver-etcd-client.crt  --from-file=etcd-client.key=/etc/kubernetes/pki/apiserver-etcd-client.key
```