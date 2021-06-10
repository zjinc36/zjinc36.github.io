#   开启firewalls

---

##  firewalls和iptables区别
https://www.jianshu.com/p/70f7efe3a227

+   从Cent7以后，iptables服务的启动脚本已被忽略。请使用firewalld来取代iptables服务
+   在RHEL7里，默认是使用firewalld来管理netfilter子系统，不过`底层调用的命令仍然是iptables`

##  firewalls操作
### 打开内网端口命令

```
#永久
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.1/24 accept'
#非永久
firewall-cmd --add-rich-rule='rule family=ipv4 source address=192.168.0.1/24 accept'
#注意修改成自己的ip段
#记得重载
firewall-cmd --reload
```

### 查看有的端口

```
firewall-cmd --zone=public --list-ports    #查看所有打开的端口
```

### 添加指定端口

```
firewall-cmd --permanent --zone=public --add-port=7103/tcp
// 记得重载
firewall-cmd --reload
```

### 移除指定端口

```
firewall-cmd --permanent --zone=public --remove-port=55222/tcp
// 记得重载
firewall-cmd --reload
```

### 常用命令介绍

```
firewall-cmd --state                           ##查看防火墙状态，是否是running
firewall-cmd --reload                          ##重新载入配置，比如添加规则之后，需要执行此命令
firewall-cmd --get-zones                       ##列出支持的zone
firewall-cmd --get-services                    ##列出支持的服务，在列表中的服务是放行的
firewall-cmd --query-service ftp               ##查看ftp服务是否支持，返回yes或者no
firewall-cmd --add-service=ftp                 ##临时开放ftp服务
firewall-cmd --add-service=ftp --permanent     ##永久开放ftp服务
firewall-cmd --remove-service=ftp --permanent  ##永久移除ftp服务
firewall-cmd --add-port=80/tcp --permanent     ##永久添加80端口 
```
