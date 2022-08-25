# kubernetes_两种容器探针

-----

容器探测用于检测容器中的应用实例是否正常工作，是保障业务可用性的一种传统机制。如果经过探测，实例的状态不符合预期，那么kubernetes就会把该问题实例“摘除”,不承担业务流量。

kubernetes提供了两种探针来实现容器探测，分别是：

+	livenessProbes: 存活性探针,用于检测应用实例当前是否处于正常运行状态,如果不是，k8s会重启容器
+	readinessProbes: 就绪性探针，用于检测应用实例当前是否可以接收请求，如果不能，k8s不会转发流量

## 三种探测方式

+	Exec命令：在容器内执行一次命令，如果命令执行的退出码是0，则认为程序正常，否则不正常

```
...
livenessProbe
  exec:
    command
    - cat
    - /tmp/health
...
```

+	HTTPGet：调用容器内Web应用的URL，如果返回的状态码在200和399之间，则认为程序正常，否则不正常

```
...
livenessProbe
  httpGet:
    path: /   # URI地址
    port: 80  # 端口号
...
```

+	TCPSocket：通过容器的IP和Port执行TCP检查，如果能够建立TCP连接，则表明容器健康。

```
...
livenessProbe
  tcpSocket:
    port: 8080
...
```

每种方式都可以定义在readiness 或者liveness 中。比如定义readiness 中http get 就是意思说如果我定义的这个path的http get 请求返回200-400以外的http code 就把我从所有有我的服务里面删了吧，如果定义在liveness里面就是把我kill 了。
注意，liveness不会重启pod，pod是否会重启由你的restart policy 控制。

## 探针探测的结果有以下三者之一

+	Success：Container通过了检查。
+	Failure：Container未通过检查。
+	Unknown：未能执行检查，因此不采取任何措施。

## 重启策略

+	Always: 总是重启
+	OnFailure: 如果失败就重启
+	Never: 永远不重启

## LivenessProbe探针配置

### 方式一:Exec

```yaml
# exec-liveness.yaml文件

apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/busybox  
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

当容器启动时，它会执行以下命令：

```bash
/bin/sh -c "touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600"
```

对于容器的前30秒，有一个/tmp/healthy文件。因此，在前30秒内，该命令cat /tmp/healthy返回成功代码。30秒后，cat /tmp/healthy返回失败代码。

在30秒内，查看Pod事件：

```
$ kubectl describe pod liveness-exec
......
......
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  15m               default-scheduler  Successfully assigned default/liveness-exec to k8s-m3
  Normal   Pulled     3m (x3 over 5m)   kubelet, k8s-m3    Successfully pulled image "k8s.gcr.io/busybox"
  Normal   Created    3m (x3 over 5m)   kubelet, k8s-m3    Created container
  Normal   Started    3m (x3 over 5m)   kubelet, k8s-m3    Started container
```

在30秒后，查看Pod事件：

```
$ kubectl describe pod liveness-exec

Events:
  Type     Reason     Age              From               Message
  ----     ------     ----             ----               -------
  Normal   Scheduled  16m              default-scheduler  Successfully assigned default/liveness-exec to k8s-m3
  Normal   Pulled     5m (x3 over 7m)  kubelet, k8s-m3    Successfully pulled image "k8s.gcr.io/busybox"
  Normal   Created    5m (x3 over 7m)  kubelet, k8s-m3    Created container
  Normal   Started    5m (x3 over 7m)  kubelet, k8s-m3    Started container
  Warning  Unhealthy  4m (x9 over 7m)  kubelet, k8s-m3    Liveness probe failed: cat: can't open '/tmp/healthy': No such file or directory
  Normal   Pulling    4m (x4 over 7m)  kubelet, k8s-m3    pulling image "k8s.gcr.io/busybox"
  Normal   Killing    2m (x4 over 6m)  kubelet, k8s-m3    Killing container with id docker://liveness:Container failed liveness probe.. Container will be killed and recreated.
```

再等30秒，确认Container已重新启动, 下面输出中RESTARTS的次数已增加：

```
$ kubectl get pod liveness-exec
NAME            READY     STATUS    RESTARTS   AGE
liveness-exec   1/1       Running   1          1m
```

### 方式二:HTTPGet

创建pod-liveness-httpget.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: k8s.gcr.io/liveness # 官方用户测试的demo镜像
    args:
    - /server
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: X-Custom-Header
          value: Awesome
      initialDelaySeconds: 3 
      periodSeconds: 3
```

在配置文件中，使用k8s.gcr.io/liveness镜像，创建出一个Pod，其中periodSeconds字段指定kubelet每3秒执行一次探测，initialDelaySeconds字段告诉kubelet延迟等待3秒，探测方式为向容器中运行的服务发送HTTP GET请求，请求8080端口下的/healthz, 任何大于或等于200且小于400的代码表示成功。任何其他代码表示失败。

10秒后，查看Pod事件以验证liveness探测失败并且Container已重新启动：

```
$ kubectl describe pod liveness-http
NAME            READY     STATUS             RESTARTS   AGE
liveness-http   1/1       RUNNING            1          1m
```

httpGet探测方式有如下可选的控制字段

+	host：要连接的主机名，默认为Pod IP，可以在http request head中设置host头部。
+	scheme: 用于连接host的协议，默认为HTTP。
+	path：http服务器上的访问URI。
+	httpHeaders：自定义HTTP请求headers，HTTP允许重复headers。
+	port： 容器上要访问端口号或名称。


### 方式三:TCPSocket

Kubelet将尝试在指定的端口上打开容器上的套接字，如果能建立连接，则表明容器健康。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: goproxy
  labels:
    app: goproxy
spec:
  containers:
  - name: goproxy
    image: k8s.gcr.io/goproxy:0.1
    ports:
    - containerPort: 8080
    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 20
```

TCP检查方式和HTTP检查方式非常相似，示例中两种探针都使用了，在容器启动5秒后，kubelet将发送第一个readinessProbe探针，这将连接到容器的8080端口，如果探测成功，则该Pod将被标识为ready，10秒后，kubelet将进行第二次连接。
除此之后，此配置还包含了livenessProbe探针，在容器启动15秒后，kubelet将发送第一个livenessProbe探针，仍然尝试连接容器的8080端口，如果连接失败则重启容器。


## ReadinessProbe探针配置

ReadinessProbe探针的使用场景livenessProbe稍有不同，有的时候应用程序可能暂时无法接受请求，比如Pod已经Running了，但是容器内应用程序尚未启动成功，在这种情况下，如果没有ReadinessProbe，则Kubernetes认为它可以处理请求了，然而此时，我们知道程序还没启动成功是不能接收用户请求的，所以不希望kubernetes把请求调度给它，则使用ReadinessProbe探针。
ReadinessProbe和livenessProbe可以使用相同探测方式，只是对Pod的处置方式不同，ReadinessProbe是将Pod IP:Port从对应的EndPoint列表中删除，而livenessProbe则Kill容器并根据Pod的重启策略来决定作出对应的措施。

ReadinessProbe探针探测容器是否已准备就绪，如果未准备就绪则kubernetes不会将流量转发给此Pod。

ReadinessProbe探针与livenessProbe一样也支持exec、httpGet、TCP的探测方式，配置方式相同，只不过是将livenessProbe字段修改为ReadinessProbe。

```yaml
readinessProbe:
 exec:
   command:
   - cat
   - /tmp/healthy
 initialDelaySeconds: 5
 periodSeconds: 5
```

## 示例一: ReadinessProbe示例

现在来看一个加入ReadinessProbe探针和一个没有ReadinessProbe探针的示例：
该示例中，创建了一个deploy，名为gogs，启动的容器运行一个类似于gitlab的应用程序，程序监听端口为3000。
这里为了模拟效果我这里原镜像做了一下修改，主要是为了延迟他的启动时间为40s后再去启动gogs的应用程序，此时就会开启3000端口，

(感兴趣的同学可以了解一下，非常爽的一个自助gitweb平台[Gogs](https://gogs.io/))

```yaml
kind: Service
apiVersion: v1
metadata:
  name: gogs
  namespace: default
spec:
  selector:
      test: gogs
  ports:
    - protocol: TCP
      port: 3000
---

kind: Deployment
apiVersion: apps/v1
metadata:
  name: gogs
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      test: gogs
  template:
    metadata:
      labels:
         test: gogs
    spec:
      containers:
      - image: test
        imagePullPolicy: IfNotPresent
        name: gogs
        ports:
          - containerPort: 3000
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: kubernetes.io/hostname
                    operator: In
                    values:
                      - k8s-m1
```

20220823151023.png

从上图可以看出来，当我创建部署之后，Pod启动18s，自身状态已Running，其READ字段，1/1 表示1个容器状态已准备就绪了，此时，对于kubernetes而言，它已经可以接收请求了，而实际上我在去访问的时候服务还无法访问，因为Gogo程序还尚启动起来，40s之后方可正常访问，所以针对于服务启动慢或者其他原因的此类程序，必须配置ReadinessProbe。

下面我加入readinessProbe

```yaml
kind: Service
apiVersion: v1
metadata:
  name: gogs
  namespace: default
spec:
  selector:
      test: gogs
  ports:
    - protocol: TCP
      port: 3000
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: gogs
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      test: gogs
  template:
    metadata:
      labels:
         test: gogs
    spec:
      containers:
      - image: test
        imagePullPolicy: IfNotPresent
        name: gogs
        ports:
          - containerPort: 3000
        readinessProbe:
          tcpSocket:
            port: 3000
          initialDelaySeconds: 10 # 启动后10秒开始探测
          periodSeconds: 5        # 每5秒探测一次
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: kubernetes.io/hostname
                    operator: In
                    values:
                      - k8s-m1
```

20220823151059.png

上图可以看出Pod虽然已处于Runnig状态，但是由于第一次探测时间未到，所以READY字段为0/1，即容器的状态为未准备就绪，在未准备就绪的情况下，其Pod对应的Service下的Endpoint也为空，所以不会有任何请求被调度进来。
当通过第一次探测的检查通过后，容器的状态自然会转为READ状态。
此后根据指定的间隔时间10s后再次探测，如果不通过，则kubernetes就会将Pod IP从EndPoint列表中移除。

## 配置探针(Probe)相关属性

探针(Probe)有许多可选字段，可以用来更加精确的控制Liveness和Readiness两种探针的行为(Probe)：

+	initialDelaySeconds：Pod启动后延迟多久才进行检查，单位：秒。
+	periodSeconds：检查的间隔时间，默认为10，单位：秒。
+	timeoutSeconds：探测的超时时间，默认为1，单位：秒。
+	successThreshold：探测失败后认为成功的最小连接成功次数，默认为1，在Liveness探针中必须为1，最小值为1。
+	failureThreshold：探测失败的重试次数，重试一定次数后将认为失败，在readiness探针中，Pod会被标记为未就绪，默认为3，最小值为1。

## 参考

+	[Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
+	[Kubernetes容器存活探测&应用自恢复](https://blog.sctux.com/2018/12/18/kubernetes-liveness/#LivenessProbe%E6%8E%A2%E9%92%88%E9%85%8D%E7%BD%AE)
