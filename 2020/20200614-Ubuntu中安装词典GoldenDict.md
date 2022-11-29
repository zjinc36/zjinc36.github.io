# Ubuntu中安装词典GoldenDict

---

# 安装

```console
sudo apt-get install goldendict
```

# 添加词库

## 离线词库

1.  离线词库下载

测试过[http://download.huzheng.org/zh\_CN/](http://download.huzheng.org/zh_CN/)
测试过[英汉:朗文5++ ·双解·例句发音](https://freemdict.com/2018/06/04/%e8%8b%b1%e6%b1%89-%e6%9c%97%e6%96%875-%c2%b7%e5%8f%8c%e8%a7%a3%c2%b7%e4%be%8b%e5%8f%a5%e5%8f%91%e9%9f%b3/)
没测试过[http://download.huzheng.org/](http://download.huzheng.org/)

添加

![](../images/2020/06/20200614003.png)

## 在线词库

参考这个:[GoldenDict 中设置在线词典](https://zhuanlan.zhihu.com/p/151810213)

### 方法一

这里添加有道`http://dict.youdao.com/search?q=%GDWORD%&ue=utf8`

![](../images/2020/06/20200614005.png)

### 方法二

将查询结果网页放到一个本地 HTML 的 iFrame 里显示，相当于将 Bing 翻译的网页重新排版以适合 GoldenDict 弹窗显示。

本地新建一个 .html 格式文件，命名随意，比如为 bingdict.html，内容如下：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset=utf-8 />
    <style>
        iframe{ width: 706px; height: 650px; margin-top:-190px; margin-left:-120px;
        }
    </style>
</head>

<body>
    <iframe id="a" frameborder="0">
    </iframe>
    <script>
    var word = location.href.slice(location.href.indexOf('?a')+3);
    document.getElementById('a').setAttribute(
        'src', 
        'https://www.bing.com/dict/search?q=' + word);
    </script>
</body>
</html>
```

菜单栏选择 【编辑】>【词典】>【词典来源】>【网站】> 添加 ，在新添加条目前勾选 【已启用】 和 【作为链接】 ，条目 【名称】 可自定义，【地址】 按以下填写：

```
file:///E:/dicts/bingdict.html?a=%GDWORD%
```

其中，`E:/dicts/bingdict.html`是我创建的 bingdict.html 的本地路径，须替换为自己的。

## 取消百科的搜索

![](../images/2020/06/20200614006.png)


## 调整词典顺序

![](../images/2020/06/20200614004.png)


# 使用

+   快捷键

![](../images/2020/06/20200614007.png)

+   屏幕取词
将需要查询的内容选取,按`ctrl + c + c`快捷键

# 教程
[安装使用 GoldenDict 查词神器 (Windows/Mac/Linux)](https://www.jianshu.com/p/b6b2c1d78d7c)

