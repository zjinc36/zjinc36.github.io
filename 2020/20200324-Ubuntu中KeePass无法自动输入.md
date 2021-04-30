---
title: Ubuntu中KeePass使用快捷键自动输入用户名密码无效
description: 错误:the xdotool utility/package is required for auto-type install this package and try again
date: 2020-03-24 15:22:19
categories:
- Ubuntu
tags:
- Ubuntu装机日志
---
#   问题
1.  按自动键入快捷键`ctrl + v`
2.  出现`the xdotool utility/package is required for auto-type install this package and try again`错误
即,keepass无法自动键入用户名和密码

#   解决

### 首先安装xdotool软件包
在Debian / Ubuntu / etc上只需运行：
```
sudo apt-get安装xdotool
```

### 接下来找出系统中安装了keepass2可执行文件的位置

最简单的方法是运行：
```
which keepass2
```
在我的系统上，这将返回`/usr/bin/keepass2`。该文件实际上不是程序本身，而是引导程序的脚本。因此，找出真正的可执行文件在哪里运行：

```
cat /usr/bin/keepass2
```
在我的系统上，这返回
```
#!/bin/sh
exec /usr/bin/cli/usr /lib/keepass2/KeePass.exe "$@"
```
因此，程序本身实际上位于`/usr/lib/keepass2/KeePass.exe`

### 创建自定义键盘快捷键
根据您所运行的发行版，此过程将有所不同，但通常在“键盘”设置下。对于命令，输入以下内容：
```
mono /usr/lib/keepass2/KeePass.exe --auto-type
```
现在，只要键入快捷键(通常是`ctrl + v`)，KeePass会自动键入配置的用户名和密码
