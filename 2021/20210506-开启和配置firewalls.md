#   开启firewalls

---
##  firewalls和iptables区别
https://www.jianshu.com/p/70f7efe3a227

+   从Cent7以后，iptables服务的启动脚本已被忽略。请使用firewalld来取代iptables服务
+   在RHEL7里，默认是使用firewalld来管理netfilter子系统，不过`底层调用的命令仍然是iptables`

##  firewalls操作

### 使用xml文件配置规则
参考:https://lpwmm.blog.csdn.net/article/details/108062623

其实网上有很多是用命令的,但实际上编辑xml文件更快也更清楚

```
vim /etc/firewalld/zones/public.xml
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Public</short>
  <description>For use in public areas. You do not trust the other computers on networks to not harm your computer. Only selected incoming connections are accepted.</description>
  <service name="ssh"/>
  <service name="dhcpv6-client"/>
  <!-- 指定端口,所以ip都能访问 -->
  <port protocol="tcp" port="55222"/>
  <!-- 允许单个IP地址访问本服务器所有端口 -->
  <rule family="ipv4">
    <source address="10.1.1.13/32"/>
    <accept/>
  </rule>
  <!-- 允许IP段访问本服务器所有端口 -->
  <rule family="ipv4">
    <source address="10.1.2.0/24"/>
    <accept/>
  </rule>
  <rule family="ipv4">
    <source address="192.168.0.1/24"/>
    <accept/>
  </rule>
  <!-- 允许IP段访问本服务器指定端口 -->
  <rule family="ipv4">
    <source address="10.1.3.0/24"/>
    <port protocol="tcp" port="22"/>
    <accept/>
  </rule>
  <!-- 允许IP段访问本服务器指定端口范围 -->
  <rule family="ipv4">
    <source address="10.1.4.0/24"/>
    <port protocol="tcp" port="1000-1200"/>
    <accept/>
  </rule>
  <!-- 禁止指定IP访问本服务器 -->
  <rule family="ipv4">
    <source address="10.1.1.1"/>
    <reject/>
  </rule>
</zone>
```

```
// 记得重载
firewall-cmd --reload
```

### 使用命令配置规则
####    打开内网端口命令
```
#永久
firewall-cmd --permanent --add-rich-rule='rule family=ipv4 source address=192.168.0.1/24 accept'
#非永久
firewall-cmd --add-rich-rule='rule family=ipv4 source address=192.168.0.1/24 accept'
#注意修改成自己的ip段
#记得重载
firewall-cmd --reload
```

####    指定ip访问特定端口
```
firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="192.168.142.166" port protocol="tcp" port="5432" accept"
```

####    查看所有打开的端口
```
firewall-cmd --zone=public --list-ports    ##查看所有打开的端口
```

####    添加指定端口
```
firewall-cmd --permanent --zone=public --add-port=7103/tcp ##添加指定端口
```

####    移除指定端口
```
firewall-cmd --permanent --zone=public --remove-port=55222/tcp ##移除指定端口
```

### 常用命令介绍
```
firewall-cmd --state ##查看防火墙状态，是否是running
firewall-cmd --reload ##重新载入配置，比如添加规则之后，需要执行此命令
firewall-cmd --get-zones ##列出支持的zone
firewall-cmd --get-services ##列出支持的服务，在列表中的服务是放行的
firewall-cmd --query-service ftp ##查看ftp服务是否支持，返回yes或者no
firewall-cmd --add-service=ftp ##临时开放ftp服务
firewall-cmd --add-service=ftp --permanent ##永久开放ftp服务
firewall-cmd --remove-service=ftp --permanent ##永久移除ftp服务
firewall-cmd --add-port=80/tcp --permanent ##永久添加80端口
```
