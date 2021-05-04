#   HTTP method GET is not supported by this URL错误
date: 2019-06-27 10:18:25
description: Servlet常见错误
tags:
- Servlet
categories:
- Java
---
##  错误详情
```
HTTP Status 405 ? Method Not Allowed

Type Status Report

Message HTTP method GET is not supported by this URL

Description The method received in the request-line is known by the origin server but not supported by the target resource.

Apache Tomcat/8.5.39 (Ubuntu)
```

##  解决方案
没有有效的doGet()方法,doGet()方法应该像下述方法一样
核心在于,要将`super.doGet(req, resp)`注释掉
```java
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        //注意,这里的super.doGet(req, resp)要进行注释
        //super.doGet(req, resp);
    }
```
