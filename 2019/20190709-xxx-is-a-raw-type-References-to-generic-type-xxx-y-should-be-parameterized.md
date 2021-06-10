#   问题:xxx is a raw type. References to generic type xxx<y> should be parameterized
+ date: 2019-07-09 10:55:11
+ description: 出现 Query is a raw type. References to generic type Query<R> should be parameterized 或者 List is a raw type. References to generic type List should be parameterized 警告
+ categories:
  - Java
+ tags:
  - Java细节
---
#   Eclipse出现如下报错
>   +   Query is a raw type. References to generic type Query<R> should be parameterized
>   或者
>   +   List is a raw type. References to generic type List should be parameterized

#   解决
##	需要知道
1.	这不是`error`而是`warning`
2.	该问题和泛型有关(要理解泛型,可以查看[https://docs.oracle.com/javase/tutorial/java/generics/index.html](https://docs.oracle.com/javase/tutorial/java/generics/index.html))

##	三种解决方式
### 知道泛型包含的是什么类型
```java
List<YourType> synchronizedpubliesdList = Collections.synchronizedList(publiesdList);
```

### 如果有多种对象则使用?通配符
```java
List<?> synchronizedpubliesdList = Collections.synchronizedList(publiesdList);
```

### 只是想摆脱警告
```java
@SuppressWarnings("rawtypes")
List synchronizedpubliesdList = Collections.synchronizedList(publiesdList);
```
