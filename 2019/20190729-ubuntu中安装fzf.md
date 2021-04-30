---
title: ubuntu中安装fzf
date: 2019-07-29 15:54:00
description: Fzf是一款小巧，超快，通用，跨平台的命令行模糊查找器
categories:
- Ubuntu
tags:
- Ubuntu装机日志
---
##  安装fzf
### 作用
Fzf是一款小巧，超快，通用，跨平台的命令行模糊查找器
### 安装
```
$ git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
$ cd ~/.fzf/
$ ./install
```

### 配置
1.  核心命令 FZF_DEFAULT_COMMAND
对于使用 fzf 来查找文件的情况，fzf 其实底层是调用的 Unix 系统 find 命令，如果你觉得 find 不好用也可以使用其它查找文件的命令行工具「我使用 fd」。注意：对原始命令添加一些参数应该在这个环境变量里面添加
比如说我们一般都会查找文件 -type f，通常会忽略一些文件夹/目录 --exclude=...，下面是我的变量值：
```bash
export FZF_DEFAULT_COMMAND="fd --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build} --type f"
```
2.  界面展示 FZF_DEFAULT_OPTS
界面展示这些参数在 fzf --help 中都有，按需配置即可
```bash
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --preview '(highlight -O ansi {} || cat {}) 2> /dev/null | head -500'"
```
`--preview`表示在右侧显示文件的预览界面，语法高亮的设置使用了[highlight](http://www.andre-simon.de/doku/highlight/en/install.php),如果 highlight 失败则使用最常见的 cat 命令来查看文件内容

### 使用
####    在Bash和Zsh中使用模糊完成
要触发文件和目录的模糊完成，请将**字符添加为触发序列
```
$ cat **<Tab>
$ unset **<Tab>
$ unalias **<Tab>
$ export **<Tab>
$ kill -9 <Tab>
```
####    启用fzf作为Vim插件
第一步:在.vimrc文件添加`set rtp+=~/.fzf`,这个指向的是fzf命令文件所在位置
第二步:进入bundles中添加`Bundle 'junegunn/fzf.vim'`,主要是为了获得更多的命令支持,不然上一步完成已经可以使用`:FZF`命令进行使用了
第三步:使用fzf插件[https://segmentfault.com/a/1190000016186540](https://segmentfault.com/a/1190000016186540)

#####   vim中使用fzf插件,写几个比较重要的
| 命令 | 作用 | 备注 |
| -------- | -------- | -------- |
| Files 路径 | FZF一样的作用，它会列出所有文件，选中后vim会打开选中的文件 | 无 |
| Buffers | 用于在存在于buffer中的文件间切换 | 无 |
| Lines <keyword> | 用于在存在于buffer里的文件中寻找含有某个关键词的行 | 无 |
| BLines <keyword> |  在当前buffer里查找 | 无 |
| Rg <keyword> | 会调用ripgrep来递归搜索当前目录 | 无 |

#### 参考
[_Fuzzy finder(fzf+vim) 使用全指南_](https://keelii.com/2018/08/12/fuzzy-finder-full-guide/)


