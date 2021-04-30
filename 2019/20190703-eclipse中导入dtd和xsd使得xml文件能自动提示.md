---
title: eclipse中导入dtd和xsd使得xml文件能自动提示
date: 2019-07-03 15:54:31
description: 在Eclipse中导入dtd和xsd文件，使XML自动提示
categories:
- Java
tags:
- Eclipse
---
##	DTD 类型约束文件
1. Window->Preferences->XML->XML Catalog->User Specified Entries窗口中,选择Add 按纽
2. 在Add XML Catalog Entry 对话框中选择或输入以下内容
```
    Location: /home/zjc/文档/Jar/hibernate-release-5.4.3.Final/project/hibernate-core/src/main/resources/org/hibernate/hibernate-mapping-3.0.dtd
    Key Type: URI
    KEY: http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd
```

##	XSD 类型约束文件
1. Window->Preferences->XML->XML Catalog->User Specified Entries窗口中,选择Add 按纽
2.在Add XML Catalog Entry 对话框中选择或输入以下内容
```
    Location: you/address/spring-beans-2.5.xsd
    Key Type: Schema Location
    KEY: http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
```
