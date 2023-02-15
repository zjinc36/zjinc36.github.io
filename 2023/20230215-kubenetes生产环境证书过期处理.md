# kubenetes生产环境证书过期处理

----

由于安全性的考虑，k8s 默认生成的 https 证书，默认有效期为1年。在运维集群的过程中，这个因素一定要有所考虑。

解决这个问题的办法，有如下几个办法：

-	定期更新证书
-	定期升级集群，因为每次升级过程中都会更新证书
-	改代码把生成的证书的有效期设置为10年或更长时间

下文就依次探讨这些方式

## 手动触发更新证书的方式

第一个问题

-	执行：`kubectl get node`
-	报错：`Unable to connect to the server: x509: certificate has expired or is not yet valid`

网上找到如下文章

-	在官网搜索资料，找到文章
	+	[https://kubesphere.com.cn/forum/d/6102-kk](https://kubesphere.com.cn/forum/d/6102-kk)
	+	[https://kubernetes.cn/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/](https://kubernetes.cn/docs/tasks/administer-cluster/kubeadm/kubeadm-certs/)
-	从这篇文章看到一个大佬出了解决方案：[https://jwangkun.github.io/OYyruQGSe/](https://jwangkun.github.io/OYyruQGSe/)
-	还有这篇：[https://jwangkun.github.io/SBgo8PNJ6/](https://jwangkun.github.io/SBgo8PNJ6/)

意思是说：`k8s证书过期，需要重新生成证书才行。于是生成k8s证书`。

注意： 手动更新证书的时候，需要每台 master 都要更新

```bash
# #检查证书有效期
$ kubeadm alpha certs check-expiration
CERTIFICATE                EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
admin.conf                 Sep 25, 2020 11:32 UTC   184d            no
apiserver                  Sep 25, 2020 11:32 UTC   184d            no
apiserver-etcd-client      Sep 25, 2020 11:20 UTC   184d            no
apiserver-kubelet-client   Sep 25, 2020 11:32 UTC   184d            no
controller-manager.conf    Sep 25, 2020 11:32 UTC   184d            no
etcd-healthcheck-client    Sep 25, 2020 11:20 UTC   184d            no
etcd-peer                  Sep 25, 2020 11:20 UTC   184d            no
etcd-server                Sep 25, 2020 11:19 UTC   184d            no
front-proxy-client         Sep 25, 2020 11:32 UTC   184d            no
scheduler.conf             Sep 25, 2020 11:32 UTC   184d            no

# # 在一台 master 上执行更新证书的操作
$ kubeadm alpha certs renew all
certificate embedded in the kubeconfig file for the admin to use and for kubeadm itself renewed
certificate for serving the Kubernetes API renewed
certificate the apiserver uses to access etcd renewed
certificate for the API server to connect to kubelet renewed
certificate embedded in the kubeconfig file for the controller manager to use renewed
certificate for liveness probes to healthcheck etcd renewed
certificate for etcd nodes to communicate with each other renewed
certificate for serving etcd renewed
certificate for the front proxy client renewed
certificate embedded in the kubeconfig file for the scheduler manager to use renewed

# #再次检查证书有效期
$ kubeadm alpha certs check-expiration
CERTIFICATE                EXPIRES                  RESIDUAL TIME   EXTERNALLY MANAGED
admin.conf                 Mar 25, 2021 03:07 UTC   364d            no
apiserver                  Mar 25, 2021 03:07 UTC   364d            no
apiserver-etcd-client      Mar 25, 2021 03:07 UTC   364d            no
apiserver-kubelet-client   Mar 25, 2021 03:07 UTC   364d            no
controller-manager.conf    Mar 25, 2021 03:07 UTC   364d            no
etcd-healthcheck-client    Mar 25, 2021 03:07 UTC   364d            no
etcd-peer                  Mar 25, 2021 03:07 UTC   364d            no
etcd-server                Mar 25, 2021 03:07 UTC   364d            no
front-proxy-client         Mar 25, 2021 03:07 UTC   364d            no
scheduler.conf             Mar 25, 2021 03:07 UTC   364d            no

# 在每台 master 集群都操作，或将生成的证书同步到其他 master 机器上
rsync -Pav -e "ssh -p 22" /etc/kubernetes/pki/  root@<master-ip>:/etc/kubernetes/pki/ 

# 定时更新证书(每月的最后1天，不一定要执行)
$ crontab -e
* * 1 * * /usr/local/bin/kubeadm alpha certs renew all
```

证书更新完又遇到第二个问题：

-	执行：`kubectl get node`
-	报错：`error: You must be logged in to the server (Unauthorized)`
-	翻译：您必须登录到服务器（未经授权）

于是又在网上找资料：[https://www.cnblogs.com/zhangmingcheng/p/14317551.html](https://www.cnblogs.com/zhangmingcheng/p/14317551.html)

这篇文章说的很详细：这个是权限问题，配置身份认证的文件为/etc/kubernetes/admin.conf，颁发证书时/etc/kubernetes/admin.conf文件重新生成，但是$HOME/.kube/config并没有得到替换。所以需要用新证书替换旧证书。

解决方案：
```bash
$ cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
```

重启所有节点，然后再执行kubectl get node，所有节点都是Ready状态，问题完美解决。

## 升级集群的时候，会自动更新证书

每次升级，只允许 1.y.z ==> 1.y.n 或者 1.y ==> 1.y+1
不允许跨多个版本的升级，比如不允许 1.14 升级到 1.16

注意：升级节点经常会遇到配置不兼容、起不来等问题，需要先在非线上环境进行验证，再操作。
kubeadm upgrade apply 在任意一台master机器操作即可。

```bash
# 先在非主节点安装新版本的包，并确认节点状态为 READY
apt install -y kubeadm kubectl kubelet

kubectl get nodes

# 在主节点安装新版本的包

# 驱逐该主 master 节点
kubectl drain <cp-node-name> --ignore-daemonsets
# 检查升级的版本
kubeadm upgrade plan
# 升级集群的配置文件
kubeadm upgrade apply v1.17.4 
```

参考：
[https://kubernetes.cn/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/](https://kubernetes.cn/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

## 修改代码，将证书时间改为 30 年

此处以 1.17 代码为例，
文件 cmd/kubeadm/app/constants/constants.go ：
再 CertificateValidity 变量下一行，再重新赋值一遍

```bash
CertificateValidity = time.Hour * 24 * 365
CertificateValidity = time.Hour * 24 * 365 * 30 
```

## 总结

以上三种方法，各有优缺点。

通过修改代码的方式，需要在集群部署时，编译 kubeadm，初始化的时候繁琐。

通过升级集群的方式，意味着基本上每隔大半年需要把所有管理的集群都升级一遍。管理的工作量略大，不一定每个团队都能接受。

通过手动触发更新证书的方式，可以结合 crontab ，似乎比较简单的达到想要的效果。当然， kubernetes 的升级机制决定了，我们必须要紧跟上游，至少每个小版本都要升级上来，不然积重难返，造成无法升级。

## 参考
-	[记一次kubesphere生产环境证书过期问题](https://www.cnblogs.com/subendong/p/15604340.html)
-	[k8s 运维之：证书更新](https://www.jianshu.com/p/f8d54e4e3247)