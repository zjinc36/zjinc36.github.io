---
title: ubuntu安装fcitx拼音和日语输入法
description: ubuntu安装fcitx拼音和日语输入法
date: 2017-05-12 10:44:44
categories:
- Ubuntu
tags:
- Ubuntu装机日志
---
#	安装fcitx框架
```
sudo apt-get install fctix
```
+   其实不用提前安装框架,底下安装输入法时,没有fctix框架的情况下,会自动安装fctix框架的
+   使用这个框架还有一个好处就是为了配合使用vim的`humiaozuzu/fcitx-status`插件
```
"""""""""" humiaozuzu/fcitx-status插件说明 """"""""""""""""
" vim输入中文在插入状态下输入中文,切换会正常模式的时候,自动检测,变成英文模式
" 被动技能
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Bundle 'humiaozuzu/fcitx-status'
```


#  安装google拼音
##  安装
1.  sudo apt-get install fcitx-googlepinyin
2.  在`settings->Language Support`里将keyboard input method system设置为fcitx
3.  注销系统，再登录
4.  在`settings->Text Entry`里，添加输入源，搜索fcitx添加即可

##  解决第二个或第三个候选字是省略号的问题
1.  原因:之所以为省略号,其实是因为这个位置是云适配候选词,但最大的问题在于这个候选词汇的源是google,而google是个什么情况心里清楚
2.  解决:将google源切换成baidu源或者关闭云服务
    +   在菜单中找到Fcitx配置(或者运行命令fcitx-configtool),打开Fcitx的配置页面,在"附件选项"中选中"云拼音",点击"配置",打开云拼音配置页面,将源改成"baidu"
    +   关闭云服务(和前面切换源同界面有关闭云服务配置,个人输入体验是关闭云服务比较好)

#   安装日语输入法anthy
```
sudo apt-get install fcitx-anthy
```

