#   Ubuntu刷新DNS
+ date: 2020-07-31 09:59:24
+ description: Ubuntu设置开机自动加/挂载硬盘
+ categories:
  - Ubuntu
+ tags:
  - Ubuntu配置
---
#   方式一:刷新DNS
```bash
sudo /etc/init.d/nscd restart
```
如果发现提示命令找不到：
```bash
sudo: /etc/init.d/nscd: command not found
```
需要先安装nscd包：
```bash
sudo apt-get install nscd
```
#   方式二:重启网络刷dns
```bash
sudo /etc/init.d/networking restart
```
