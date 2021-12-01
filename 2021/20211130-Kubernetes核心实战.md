# Kubernetes核心实战

--------

## 资源创建方式

+   命令行
+   YAML 

## Namespace

名称空间用来隔离资源

### 命令行方式

```bash
# 创建namespace
kubectl create ns hello
# 删除namespace
kubectl delete ns hello
```

### yaml方式

```bash
vim hello.yml
```

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello   # 命名空间的名字
```

```bash
# 创建namespace
kubectl apply -f hello.yml
# 删除namespace
kubectl delete -f hello.yml
```

## Pod


运行中的一组容器，Pod是kubernetes中应用的最小单位.

![](../images/2021/11/20211130223640.png)

![](../images/2021/11/20211130222209.png)


### 命令行方式

+   启动一个pod

```bash
# 启动一个pod,指定pod名为mynginx,里面的镜像为nginx,默认是在default命名空间
# 这里学习用,更多的是使用deployment进行部署,后面会说到
kubectl run mynginx --image=nginx
```

+   查看default名称空间的Pod

```bash
kubectl get pod 
kubectl get pod -n default  # 上一句和这一句是一样的,因为不写命名空间这默认命名空间是default
```

+   描述

```bash
kubectl describe pod 你自己的Pod名字
```

就是看详细过程,打开后我们拉到最低下主要看`Enents`

![](../images/2021/11/20211130223418.png)

+   删除

```bash
kubectl delete pod Pod名字
```

+   查看Pod的运行日志

```bash
kubectl logs Pod名字
```

+   查看更详细的pod的信息

```bash
# k8s会给每个Pod会分配一个ip
kubectl get pod -owide

# 使用 pod的ip + pod里面运行容器的端口
curl 192.168.169.136

# 集群中的任意一个机器以及任意的应用都能通过Pod分配的ip来访问这个Pod
# 为什么是192.168.x.x网段,是因为我们初始化的时候设置的
```

+   进入pod

```bash
kubectl exec -it pod名称 -- /bin/bash
```

也可以通过图形化界面

![](../images/2021/12/20211201155736.png)

### yaml方式

+ 一个pod一个容器

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: mynginx
  name: mynginx
#  namespace: default
spec:
  containers:
  - image: nginx
    name: mynginx
```

+ 一个pod多个容器

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: myapp
  name: myapp
spec:
  containers:   # pod内容器内容
  - image: nginx
    name: nginx
  - image: tomcat:8.5.68
    name: tomcat
```

对于pod内的多个容器,k8s会分配不同的ip,宿主机访问pod可以通过这个内网ip进行访问(比如:curl 192.168.36.68:8080)

对于pod内部的容器相互访问,只需要使用127.0.0.1进行访问就行(比如:curl 127.0.0.1:8080)

![](../images/2021/12/20211201162722.png)

如果一个pod内启动两个端口相同的容器,会启动失败

![](../images/2021/12/20211201164350.png)

![](../images/2021/12/20211201164437.png)

+ 使用yaml文件

```bash
# 创建
kubectl apply -f xxx.yml
# 删除pod
kubectl delete -f xxx.yml
```

此时的应用还不能外部访问

##  Deployment

### 基础命令

控制Pod，使Pod拥有多副本，自愈，扩缩容等能力

+ 部署应用

```bash
kubectl create deployment mytomcat --image=tomcat:8.5.68
```

和我们直接创建pod(`kubectl run mynginx --image=tomcat:8.5.68`)是不一样的,用deployment进行部署会拥有治愈能力


+ 查看所有deployment

```bash
kubectl get deploy    # deployment单词不用写全
```

+ 删除deployment

```bash
kubectl delete deploy Deployment名字
```

### 多副本

```bash
kubectl create deployment my-dep --image=nginx --replicas=3
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: my-dep
  name: my-dep
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-dep
  template:
    metadata:
      labels:
        app: my-dep
    spec:
      containers:
      - image: nginx
        name: nginx
```

### 扩缩容

命令行

```bash
kubectl scale --replicas=5 deployment/my-dep
```

修改yaml文件

```bash
# 在打开的文件中修改replicas
kubectl edit deployment my-dep
```

使用图形界面

![](../images/2021/12/20211201172449.png)

这里是手动操作,k8s是可以动态扩缩容的

### 自愈&故障转移

+ 停机
+ 删除Pod
+ 容器崩溃
+ ....


### 滚动更新

```bash
kubectl set image deployment/my-dep nginx=nginx:1.16.1 --record
kubectl rollout status deployment/my-dep
````

```
# 修改
kubectl edit deployment/my-dep
```

### 版本回退

```bash
#历史记录
kubectl rollout history deployment/my-dep


#查看某个历史详情
kubectl rollout history deployment/my-dep --revision=2

#回滚(回到上次)
kubectl rollout undo deployment/my-dep

#回滚(回到指定版本)
kubectl rollout undo deployment/my-dep --to-revision=2
````

### 更多

除了Deployment，k8s还有 StatefulSet 、DaemonSet 、Job  等 类型资源。我们都称为工作负载。

有状态应用使用 StatefulSet 部署，无状态应用使用 Deployment 部署

https://kubernetes.io/zh/docs/concepts/workloads/controllers/




