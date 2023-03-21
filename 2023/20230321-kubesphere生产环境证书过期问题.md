# kubesphere生产环境证书过期问题

2021-11-25日早上，实施反馈现场无法使用kubesphere部署应用。于是我到生产环境排查问题，一开始只是发现web ui上websocket连接报了异常。而且点击了重新部署没有任何反应。F12查看，接口是调用了，但任何反应都没有。于是建议实施重启4个节点的服务器，结果服务器起来后依然无法重新部署。以往遇到问题重启服务器就好了啊，这次是什么幺蛾子？不是说好的重启能解决90%的问题吗？然后执行命令：kubectl get node查看节点状态，结果报错，继续看下面。

先说第一个问题：
执行：kubectl get node
报错：`Unable to connect to the server: x509: certificate has expired or is not yet valid`

后来在官网搜索资料，找到一篇文章：https://kubesphere.com.cn/forum/d/6102-kk
从这篇文章看到一个大佬出了解决方案：https://jwangkun.github.io/OYyruQGSe/
还有这篇：https://jwangkun.github.io/SBgo8PNJ6/
意思是说：k8s证书过期，需要重新生成证书才行。于是生成k8s证书。

```bash
# 1.查看现有证书到期时间
$ kubeadm alpha certs check-expiration
# 2.使用二进制更新证书
$ kubeadm alpha certs renew all
# 3.每月的最后1天
$ crontab -e
* * 1 * * /usr/local/bin/kubeadm alpha certs renew all
```

第三个是利用linux的crontab表达式定期更新证书。其实只要在master上执行第二步就行了。第二步执行完，再使用第一步的命令查看证书到期时间。

证书更新完又遇到第二个问题：
执行：kubectl get node
报错：`error: You must be logged in to the server (Unauthorized)`
翻译：您必须登录到服务器（未经授权）

于是又在网上找资料：https://www.cnblogs.com/zhangmingcheng/p/14317551.html
这篇文章说的很详细：这个是权限问题，配置身份认证的文件为/etc/kubernetes/admin.conf，颁发证书时/etc/kubernetes/admin.conf文件重新生成，但是$HOME/.kube/config并没有得到替换。所以需要用新证书替换旧证书。

解决方案：

```bashy
$ cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

重启所有节点，然后再执行kubectl get node，所有节点都是Ready状态，问题完美解决。

# 重启

重启kubelet

```bash
systemctl restart kubelet
```

重启 kube-apiserver,kube-controller,kube-scheduler,etcd 这4个容器：

```bash
docker ps | grep -v pause | grep -E "etcd|scheduler|controller|apiserver" | awk '{print $1}' | awk '{print "docker","restart",$1}' | bash
```
