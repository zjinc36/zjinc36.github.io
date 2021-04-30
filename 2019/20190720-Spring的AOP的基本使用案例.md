---
title: Spring的AOP的基本使用案例
date: 2019-07-20 22:31:18
description: Spring的AOP的入门开发
categories:
- Java
tags:
- Spring
---
本质上就是将面向切面变成要写的一堆代码变成只需要配置xml文件就可以了
##	ProductDao.java
```java
package com.zjinc36.spring.aop;

public interface ProductDao {
	public void save();
	public void update();
}
```
##	ProductDaoImpl.java
```java
package com.zjinc36.spring.aop;

public class ProductDaoImpl implements ProductDao {

	@Override
	public void save() {
		System.out.println("save");
	}

	@Override
	public void update() {
		System.out.println("update");
	}

}
```

##	写切面类
```java
package com.zjinc36.spring.aop;

/**
 * 切面类
 * @author zjc
 *
 */
public class MyAspectXML {
	public void checkPri() {
		System.out.println("权限校验");
	}
}
```

##	applicationContext.xml
[_参考:切点表达式写法_](/2019/07/21/Spring的切点表达式写法/)
[_参考:Spring的通知类型_](/2019/07/21/Spring的通知类型/)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:context="http://www.springframework.org/schema/context"
	xmlns:aop="http://www.springframework.org/schema/aop"
	xsi:schemaLocation="
		http://www.springframework.org/schema/beans
		http://www.springframework.org/schema/beans/spring-beans.xsd
		http://www.springframework.org/schema/aop
		http://www.springframework.org/schema/aop/spring-aop.xsd
	">

	<bean id="productDao" class="com.zjinc36.spring.aop.ProductDaoImpl"></bean>

	<!-- 将切面类交给Spring管理 -->
	<bean id="myAspect" class="com.zjinc36.spring.aop.MyAspectXML" />

	<!-- 通过AOP的配置完成对目标类产生代理 -->
	<aop:config>
		<!--
			表达式配置哪些类的哪些方法需要进行增强
			对哪些点进行拦截
			*	表示任意返回值
			..	表示任意参数
		 -->
		<aop:pointcut expression="execution(* com.zjinc36.spring.aop.ProductDaoImpl.save(..) )" id="product1" />

		<!-- 配置切面 -->
		<!--
			ref:切面id
		 -->
		<aop:aspect ref="myAspect">
			<aop:before method="checkPri" pointcut-ref="product1" />
		</aop:aspect>
	</aop:config>
</beans>
```

##	测试
```java
package com.zjinc36.spring.test;

import javax.annotation.Resource;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.zjinc36.spring.aop.ProductDao;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:applicationContext.xml"})
public class TestProductAOP {
	@Resource(name = "productDao")
	private ProductDao productDao;

	@Test
	public void demo1() {
		productDao.save();
		productDao.update();
	}
}
```
