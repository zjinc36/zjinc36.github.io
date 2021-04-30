---
title: java用jackson包实现json、对象、Map之间的转换
date: 2019-11-12 10:25:25
description: java用jackson包实现json、对象、Map之间的转换
categories:
- Java
tags:
- Jackson
---
##	将对象转换成json
```java
ObjectMapper mapper = new ObjectMapper(); //转换器 
String jsonStr = mapper.writeValueAsString(user);
```

##	json转换成map
```java
Map m = mapper.readValue(json, Map.class); 
```

##	map转json
```java
String jsonStr = mapper.writeValueAsString(m);
```

##	json转java对象
```java
User user = mapper.readValue(json, User.class);
```

