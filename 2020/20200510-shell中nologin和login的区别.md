---
title: shell中no login和login的区别
description: shell中no login和login的区别
date: 2020-05-10 19:00:36
categories:
- Ubuntu
tags:
- Linux配置
---
#   什么是nologin shell和login shell？
按照bash文档的说法，login shell是第0个参数以`-`开头或者有一个参数为`-login`的shell。

>   A login shell is one whose first character of argument zero is a -, or one started with the --login option.

+   根据该定义，我们可以使用`bash --login`启动一个login shell或者通过`echo $0`的输出结果是否以`-`开头来判断一个shell是否为login shell。
+   经过测试
    -   通过图形界面启动的终端为no login shell
    -   通过ssh远程连接得到的shell为login shell。

#   为什么要关注是login shell还是no login shell？
区分login shell和no login shell的主要原因是它们启动和退出时自动执行的脚本不同。

##   login shell
对于login shell其启动时自动执行的脚本文件顺序如下
1.  首先执行`/etc/profile`
2.  再执行`~/.bash_profile`, `~/.bash_login`, `~/.profile`中第一个存在的脚本（按顺序搜索，只会执行其中一个）

如果shell启动时添加了`--noprofile`选项则不会执行上述文件。在login shell退出时，会执行`~/.bash_logout`

##   no login shell

对于no login shell，启动时会执行`/etc/bash.bashrc`和`~/.bashrc`，如果shell启动时添加了`--norc`选项则不会执行上述文件，如果添加了`--rcfile <filename>`选项则会执行指定的filename文件，也不会执行上述文件。no login shell退出时不会自动执行脚本文件。

#   总结
+   no login shell和login shell在启动和退出时会执行不同的脚本文件从而影响shell中的环境变量，本文根据bash的文档描述了两种shell启动时自动执行的脚本文件的区别。
+   login shell和no login shell启动时执行的脚本文件是完全不同的，因此，运行环境初始化脚本需要合理配置才能让login shell和no login shell都能执行，同时也可以为login shell和no login shell配置不同的运行环境初始化脚本。

#   参考资料
+   [Linux man page(bash)](https://linux.die.net/man/1/bash)
+   [no login shell和login shell](https://blog.csdn.net/j5856004/article/details/100638931)
