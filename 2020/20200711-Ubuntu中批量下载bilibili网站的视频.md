#   Ubuntu中批量下载bilibili网站的视频
description: Ubuntu中批量下载bilibili网站的视频
date: 2020-07-11 11:50:44
categories:
- Ubuntu
tags:
- Ubuntu装机日志
---
#   方案一:you-get
##  项目地址
[Github地址:https://github.com/soimort/you-get](https://github.com/soimort/you-get)

##  安装
```shell
pip3 install you-get #安装You-Get
pip3 install --upgrade you-get #升级You-Get
```

##  使用
```shell
you-get --playlist -o ./ https://www.bilibili.com/video/视频地址\?p\=1
```


#   方案二
##  项目地址
[Github地址:https://github.com/Henryhaohao/Bilibili_video_download](https://github.com/Henryhaohao/Bilibili_video_download)

##  使用
1.  将项目克隆到本地
2.  运行

```shell
python /your/address/bilibili_video_download.py
```

