#   Ubuntu的Shell中使用Ack进行搜索
description: Ubuntu的Shell中使用Ack进行搜索
date: 2017-05-16 23:28:16
categories:
- Ubuntu
tags:
- Linux命令
---
#   安装
```
$ wget http://beyondgrep.com/ack-2.12-single-file
$ sudo mv ack-2.12-single-file /usr/bin/ack
$ sudo chmod 0755 /usr/bin/ack
```

#   ack的使用案例
1.  在当前目录递归搜索单词”eat”,不匹配类似于”feature”或”eating”的字符串:
```
$ ack -w eat
```

2.  搜索有特殊字符的字符串’$path=.’,所有的元字符（比如’$',’.')需要在字面上被匹配:
```
$ ack -Q '$path=.' /etc
```

3.  除了dowloads目录，在所有目录搜索”about”单词:
```
$ ack about --ignore-dir=downloads
```

4.  只搜索包含’protected’单词的PHP文件，然后通过文件名把搜索结果整合在一起，打印每个文件对应的搜索结果:
```
$ ack --php --group protected
```

5.  获取包含’CFLAG’关键字的Makefile的文件名。文件名为`*.mk,makefile,Makefile,GNUmakefile`的都在考虑范围内:
```
$ ack --make -l CFLAG
```

6.  显示整个日志文件时高亮匹配到的字符串:
```
$ tail -f /var/log/syslog | ack --passthru 192.168.1.10
```

7.  要换取ack支持的文件过滤类型，运行：
```
$ ack --help-type
```


