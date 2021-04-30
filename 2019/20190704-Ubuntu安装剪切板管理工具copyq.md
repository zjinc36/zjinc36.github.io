---
title: Ubuntu安装剪切板管理工具copyq
date: 2019-07-04 09:52:52
description: CopyQ 是一个简单但是非常有用的剪贴板管理器，它保存你的系统剪贴板内容，无论你做了什么改变，你都可以在你需要的时候搜索和恢复它
categories:
- Ubuntu
tags:
- Ubuntu装机日志
---
## 作用
CopyQ 是一个简单但是非常有用的剪贴板管理器，它保存你的系统剪贴板内容，无论你做了什么改变，你都可以在你需要的时候搜索和恢复它。它是一个很棒的工具，支持文本、图像、HTML 和其它格式。
CopyQ 自身有很多功能像拖放、复制/拷贝、编辑、移除、排序、创建等。它同样支持集成文本编辑器，如 Vim，所以如果你是程序员，这非常有用。
## 安装
```
$ sudo add-apt-repository ppa:hluk/copyq
$ sudo apt-get update
$ sudo apt-get install copyq
```
## 个人习惯配置
```
+   打开首选项
+   常规 -> 将`用鼠标选择存储文本`打勾
+   常规 -> 将`run automatic commands on selection`去除
+   快捷键 -> 显示/隐藏主窗口 -> 增加快捷键`ctrl+shift+v`
```
