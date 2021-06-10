#   String直接赋值与使用new String的区别
date: 2019-06-27 16:18:36
description: 研究String直接赋值与new String的区别
copyright: false
tags:
- Java细节
categories:
- Java
---

>   **原文标题**:String直接赋值与使用new String的区别
>   **原文链接**:[https://blog.csdn.net/weixin_41098980/article/details/80060200](https://blog.csdn.net/weixin_41098980/article/details/80060200)

-----------------------

在研究String直接赋值与new String的区别之前我们需要先了解java中的字符串常量池的概念

##  字符串常量池
String类是我们平常项目中使用频率非常高的一种对象类型，jvm为了提升性能和减少内存开销，避免字符的重复创建，其维护了一块特殊的内存空间，即字符串池，当需要使用字符串时，先去字符串池中查看该字符串是否已经存在，如果存在，则可以直接使用，如果不存在，初始化，并将该字符串放入字符创常量池中。

##  使用String直接赋值
String str = “abc”;可能创建一个或者不创建对象，如果”abc”在字符串池中不存在，会在java字符串池中创建一个String对象（”abc”），然后str指向这个内存地址，无论以后用这种方式创建多少个值为”abc”的字符串对象，始终只有一个内存地址被分配。==判断的是对象的内存地址，而equals判断的是对象内容。通过以下代码测试：
```java
String str = "abc";
String str1 = "abc";
String str2 = "abc";
System.out.println(str==str1);//true
System.out.println(str==str2);//true
```
也就是str、str1、str2都是指向同一个内存地址。

##  使用new String 创建字符串
String str = new String(“abc”);至少会创建一个对象，也有可能创建两个。因为用到new关键字，肯定会在堆中创建一个String对象，如果字符池中已经存在”abc”,则不会在字符串池中创建一个String对象，如果不存在，则会在字符串常量池中也创建一个对象。
```java
String str = new String("abc");
String str1 = new String("abc");
String str2 = new String("abc");
System.out.println(str==str1);//false
System.out.println(str==str2);//false
```
可以看出来，str、str1、str2指向的是不同的内存地址

##  使用String拼接字符串
项目中除了直接使用=赋值，也会用到字符串拼接，字符串拼接又分为变量拼接和已知字符串拼接
```java
String str = "abc";//在常量池中创建abc
String str1 = "abcd";//在常量池中创建abcd
String str2 = str+"d";//拼接字符串，此时会在堆中新建一个abcd的对象，因为str2编译之前是未知的
String str3 = "abc"+"d";//拼接之后str3还是abcd，所以还是会指向字符串常量池的内存地址
System.out.println(str1==str2);//false
System.out.println(str1==str3);//true
```
所以在项目中还是不要使用new String去创建字符串，最好使用String直接赋值。
