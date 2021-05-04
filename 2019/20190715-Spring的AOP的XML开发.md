#   Spring的AOP的XML开发
+ date: 2019-07-15 10:38:51
+ description: Spring的AOP的xml开发
+ categories:
  - Java
+ tags:
  - Spring
---
#   AOP概述
AOP，Aspect Oriented Programming，面向切面编程，是指在运行时，动态地将代码切入到类的指定方法、指定位置上的一种编程技术。AOP 是 OOP 的延续，是软件开发中的一个热点，也是 Spring 框架中的一个重要内容。利用 AOP 可以对业务逻辑与横切关注点（cross-cutting concerns，例如日志记录，事务处理）进行隔离，从而使得业务逻辑与横切关注点的耦合度降低，提高程序的可重用性，同时提高了开发的效率。

AOP 目的是为了解耦，它可以使一组类共享相同的行为。面向对象编程（OOP）目的也是为了提高代码的可重用性，那么 AOP 和 OOP 有什么不同之处呢？对于 OOP 来说，只能通过继承类和实现接口这种方式来实现，但这会使代码的耦合程度增强，不利于代码的维护。AOP 正是为了弥补了 OOP 的不足而出现。

Spring 框架提供了 AOP 的丰富支持，允许开发人员通过分离应用程序的业务逻辑与横切关注点从而进行内聚性的开发。举例来说，日志记录，性能统计，安全控制，事务处理，异常处理，这些称之为横切关注点的功能，对于应用程序来说是必须的。AOP 允许将这些横切关注点从业务逻辑代码中划分出来，从而改变这些横切关注点的代码不影响业务逻辑的代码。

#	Spring底层的AOP实现原理
动态代理
+	JDK动态代理:只能对实现了接口的类产生代理
+	Cglib动态代理:类似于Javassist第三方代理技术,对没有实现接口的类产生代理对象,生成子类对象
##	JDK动态代理
[_参见:设计模式之代理模式_](/2019/07/16/Spring的代理模式/#动态代理)

1.  UserDao
```java
package com.zjinc36.spring.aop;

public interface UserDao {
	public void save();
	public void update();
}
```

2.	继承UserImpl
```java
package com.zjinc36.spring.aop;

public class UserDaoImpl implements UserDao {

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

3.	动态代理,面向UserDao接口
```java
package com.zjinc36.spring.aop;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/**
 * 使用JDK动态代理对UserDao产生代理
 * @author zjc
 */
public class JdkProxy implements InvocationHandler {
	// 将被增强的对象传递到代理中
	private UserDao userDao;

	public JdkProxy(UserDao userDao) {
		this.userDao = userDao;
	}

	public UserDao createProxy() {
		UserDao userDaoProxy = (UserDao) Proxy.newProxyInstance(
				userDao.getClass().getClassLoader(),
				userDao.getClass().getInterfaces(), this);
		return userDaoProxy;
	}

	@Override
	public Object invoke(Object proxy, Method method, Object[] args)
			throws Throwable {
		// 判断方法名是不是save
		if ("save".equals(method.getName())) {
			System.out.println("save power up");
			return method.invoke(userDao, args);
		}
		return method.invoke(userDao, args);
	}

}
```

4.	测试
```java
package com.zjinc36.spring.test;

import org.junit.Test;

import com.zjinc36.spring.aop.JdkProxy;
import com.zjinc36.spring.aop.UserDao;
import com.zjinc36.spring.aop.UserDaoImpl;

public class TestAOP {
	@Test
	public void demo1() {
		UserDao userDao = new UserDaoImpl();
		//创建代理
		UserDao proxy = new JdkProxy(userDao).createProxy();
		proxy.save();
		proxy.update();
	}
}

```
##	Cglib动态代理
第三方开源代码生成类库,动态添加类的属性和方法

Spring已经核心包已经引入Cglib包了

1.	创建CustomerDao对象
```java
package com.zjinc36.spring.aop;

public class CustomerDao {
	public void save() {
		System.out.println("save");
	}
	public void update() {
		System.out.println("update");
	}
}
```

2.	动态代理
```java
package com.zjinc36.spring.aop;

import java.lang.reflect.Method;

import org.springframework.cglib.proxy.Enhancer;
import org.springframework.cglib.proxy.MethodInterceptor;
import org.springframework.cglib.proxy.MethodProxy;

/**
 * Cglib动态代理
 * @author zjc
 *
 */
public class CglibProxy implements MethodInterceptor {
	private CustomerDao customerDao;

	public CglibProxy(CustomerDao customerDao) {
		this.customerDao = customerDao;
	}

	/**
	 * 使用Cglib产生代理的方法
	 */
	public CustomerDao createProxy() {
		// 1.创建cglib核心类对象
		Enhancer enhancer = new Enhancer();
		// 2.设置父类
		enhancer.setSuperclass(customerDao.getClass());
		// 3.设置回调(类似于InvocationHandler对象)
		enhancer.setCallback(this);
		// 4.创建代理对象
		CustomerDao proxy = (CustomerDao) enhancer.create();
		return proxy;
	}

	@Override
	public Object intercept(Object proxy, Method method, Object[] arg,
			MethodProxy methodProxy) throws Throwable {
		if ("save".equals(method.getName())) {
			System.out.println("save power up");
			return methodProxy.invokeSuper(proxy, arg);
		}
		return methodProxy.invokeSuper(proxy, arg);
	}
}
```

3.	测试
```java
	@Test
	public void demo2() {
		CustomerDao customerDao = new CustomerDao();
		//创建代理
		CustomerDao proxy = new CglibProxy(customerDao).createProxy();
		proxy.save();
		proxy.update();
	}
```

#   AspectJ
##  AspectJ简介
+   Spring的AOP有自己的实现方式(非常繁琐),AspectJ是一个AOP框架,Spring引入AspectJ作为自身AOP的开发
+   Spring两套AOP开发方式
>   +   Spring传统方式(已弃用)
>   +   Spring基于AspectJ的AOP的开发(使用)

## AOP的相关术语
|相关术语|通俗理解|作用|
|----|----|----|
|Joinpoint(连接点)|可以被拦截到的点|所谓连接点是指那些被拦截到的点。在spring中,这些点指的是方法,因为spring只支持方法类型的连接点.|
|Pointcut(切入点)|真正拦截到的点|所谓切入点是指我们要对哪些Joinpoint进行拦截的定义|
|Advice(通知/增强)|方法层面的增强|所谓通知是指拦截到Joinpoint之后所要做的事情就是通知.通知分为前置通知,后置通知,异常通知,最终通知,环绕通知(切面要完成的功能)|
|Introduction(引介)|类层面的增强|引介是一种特殊的通知在不修改类代码的前提下, Introduction可以在运行期为类动态地添加一些方法或Field.|
|Target(目标对象)|被增强的对象|代理的目标对象|
|Weaving(织入)|将Advice应用到Target的过程|是指把增强应用到目标对象来创建新的代理对象的过程.spring采用动态代理织入，而AspectJ采用编译期织入和类装在期织入|
|Proxy（代理）|代理对象|一个类被AOP织入增强后，就产生一个结果代理类|
|Aspect(切面)|切面|是切入点和通知（引介）的结合|

##   AspectJ的XML的方式开发
