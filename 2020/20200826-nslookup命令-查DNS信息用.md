#   nslookup命令-查DNS信息用
+ date: 2020-08-26 12:35:29
+ description: nslookup命令-查DNS信息用
+ categories:
  - Ubuntu
+ tags:
  - Linux命令
---
#   基本说明
 nslookup命令是常用域名查询工具，就是查DNS信息用的命令。

nslookup4有两种工作模式，即“交互模式”和“非交互模式”。在“交互模式”下，用户可以向域名服务器查询各类主机、域名的信息，或者输出域名中的主机列表。而在“非交互模式”下，用户可以针对一个主机或域名仅仅获取特定的名称或所需信息。

进入交互模式，直接输入nslookup命令，不加任何参数，则直接进入交互模式，此时nslookup会连接到默认的域名服务器（即/etc/resolv.conf的第一个dns地址）。或者输入nslookup -nameserver/ip。进入非交互模式，就直接输入nslookup 域名就可以了。


#   语法
nslookup(选项)(参数)

#   选项
+   -sil：不显示任何警告信息。

#   参数
域名：指定要查询域名。

#   实例
```console
[root@localhost ~]# nslookup www.linuxde.net
Server:         202.96.104.15
Address:        202.96.104.15#53

Non-authoritative answer:
www.linuxde.net canonical name = host.1.linuxde.net.
Name:   host.1.linuxde.net
Address: 100.42.212.8
```

#   参考
+   [如何在Ubuntu和Debian中设置永久DNSNameservers](https://www.howtoing.com/set-permanent-dns-nameservers-in-ubuntu-debian)
+   [ubuntu 修改 DNS 的方法](https://www.runoob.com/w3cnote/ubuntu-modify-dns.html)
