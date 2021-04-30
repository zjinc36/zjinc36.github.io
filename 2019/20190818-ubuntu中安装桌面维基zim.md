---
title: ubuntu中安装桌面维基zim
date: 2019-08-18 16:49:05
description: Zim是一个图形文本编辑器，用于维护一组wiki页面
categories:
- Ubuntu
tags:
- Ubuntu装机日志
---
#   zim是什么
Zim是一个图形文本编辑器，用于维护一组wiki页面。

#   zim的作用
每个页面都可以包含指向其他页面的链接，简单的格式和图像。页面存储在文件夹结构中，就像在大纲中一样，并且可以具有附件。创建新页面就像链接到不存在的页面一样简单。所有数据都存储在具有wiki格式的纯文本文件中。各种插件提供附加功能，如任务列表管理器，公式编辑器，托盘图标和版本控制支持。

Zim可用于：
+	保留笔记存档
+	保留每日或每周日记
+	在会议或讲座期间做笔记
+	组织任务列表
+	撰写博客条目和电子邮件
+	做头脑风暴

#   官网
[https://zim-wiki.org/](https://zim-wiki.org/)

#   安装
```
sudo add-apt-repository ppa:jaap.karssenberg/zim
sudo apt-get update
sudo apt-get install zim
```
