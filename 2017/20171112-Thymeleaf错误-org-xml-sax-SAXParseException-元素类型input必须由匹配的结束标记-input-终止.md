---
title: org.xml.sax.SAXParseException:元素类型input必须由匹配的结束标记/input终止
date: 2017-11-12 10:36:16
description: org.xml.sax.SAXParseException:元素类型input必须由匹配的结束标记/input终止
categories:
- Java
tags:
- Java细节
- Thymeleaf
---
#   参考与引用
[https://github.com/thymeleaf/thymeleaf/issues/390](https://github.com/thymeleaf/thymeleaf/issues/390)
[http://nekohtml.sourceforge.net/](http://nekohtml.sourceforge.net/)
[NekoHTML 学习笔记](https://blog.csdn.net/kydkong/article/details/77507798)
[Thymeleaf 3 引入了新的解析系统](https://waylau.com/thymeleaf-3-adopts-a-new-parsing-system/)


#   问题
如果你的代码使用了 HTML5 的标准，而Thymeleaf 版本来停留在 2.x ，那么如果没有把`<input>`闭合，如下：
```html
<form>
    First name:<br>
    <input type="text" name="firstname">
    <br>
    Last name:<br>
    <input type="text" name="lastname">
</form>
```
就会抛出如下错误

```
org.xml.sax.SAXParseException: 元素类型 "input" 必须由匹配的结束标记 "</input>" 终止。
```

#   解决方案
##  沿用 Thymeleaf 老版本的情况
### 方案一(废话)
如果你的 Thymeleaf 不能变更，那么你的 HTML 标准也只能停留在老版本了。你必须严格遵守 XML 定义，在`<input>`加上结束标记`</input>`。这显然，对于 HTML5 不友好。

### 方案二:使用第三方包nekohtml
```
<dependency>
   <groupId>net.sourceforge.nekohtml</groupId>
   <artifactId>nekohtml</artifactId>
   <version>1.9.15</version>
</dependency>
```
_NekoHTML 是一个简单地HTML扫描器和标签补偿器(tag balancer) ,使得程序能解析HTML文档并用标准的XML接口来访问其中的信息。这个解析器能投扫描HTML文件并“修正”许多作者（人或机器）在编写HTML文档过程中常犯的错误。NekoHTML 能增补缺失的父元素、自动用结束标签关闭相应的元素，以及不匹配的内嵌元素标签。NekoHTML 的开发使用了Xerces Native Interface (XNI)，后者是Xerces2的实现基础。_

##  方案三:升级至 Thymeleaf 3 新版本
是时候尝试下使用 Thymeleaf 3 了。Thymeleaf 3 使用了新的解析系统。

Thymeleaf 3 不再是基于XML结构的。由于引入新的解析引擎，模板的内容格式不再需要严格遵守XML规范。即不在要求标签闭合，属性加引号等等。当然，出于易读性考虑，还是推荐你按找XML的标准去编写模板。

Thymeleaf 3 使用一个名为 AttoParser 2的新解析器。 一个新的、基于事件（不符合SAX标准）的解析器，AttoParser由 Thymeleaf 的作者开发，符合 Thymeleaf 的风格。

### AttoParser 提供 Thymeleaf 3 两个重要功能：
+   完全支持XML和HTML5（非XML化）标记，从而不再需要外部标记平衡操作。
+   无损解析，以便在处理的输出的标记类似于具有最高精度的原始模板。

所以下面的格式在 Thymeleaf 3 里面是合法的：
```
<div><img alt=logo th:src='@{/images/logo.png}'>
```

### Thymeleaf 3 其他方面的解析改进
1. 启用验证的解析
在 Thymeleaf 2.1提供了两种VALID\*模板模式，名为VALIDXHTML和VALIDXML，在而 Thymeleaf 3 中将不再存在。 新的解析基础结构不提供HTML或XML验证，即在解析期间无法验证模板标记是否符合指定的DTD或XML模式定义。

2. 不再需要`<![CDATA[ ... ]]>`

Thymeleaf 2.1 要求将`<script>`标记的内容封装在 CDATA 中，以便所使用的任何<或>符号不会干扰基于XML的解析：
```javascript
<script>
/*<![CDATA[*/
  var user = ...
  if (user.signupYear < 1990) {
    alert('You\'ve been here for a long time!');
  }
/*]]>*/
</script>
```
而在 Thymeleaf 3 中则不需要这样做，代码立马变得简洁干净：
```javascript
<script>
  var user = ...
  if (user.signupYear < 1990) {
    alert('You\'ve been here for a long time!');
  }
</script>
```
