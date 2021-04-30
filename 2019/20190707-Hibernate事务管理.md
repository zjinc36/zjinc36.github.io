---
title: Hibernate事务管理
date: 2019-07-07 23:11:59
description: Hibernate事物管理
categories:
- Java
tags:
- Hibernate
---
#   事务
##   什么是事务
事务指的是逻辑上的一组操作,组成这组操作的各个逻辑单元,要么全部成功,要么全部失败

##  事务特性
+   原子性:代表事务不可分割
+   一致性:代表事务执行的前后,数据的完整性保持一致
+   隔离性:代表一个事务执行的过程中,不应该收到其他事务的干扰
+   持久性:代表事务执行完成后,数据就持久到数据库中

##  如果不考虑隔离性,引发安全问题
### 读问题
+   脏读:一个事务读到另一个事务未提交的数据
+   不可重复读:一个事务读到另一个事务已经提交的update数据,导致在前一个事务多次查询结果不一致
+   虚读:一个事务读到另一个事务已经提交的insert数据,导致在前一个事务多次查询结果不一致

### 写问题(了解)
引发两类丢失更新

##  读问题的解决
+   Read uncommitted:以上读问题都会发生
+   Read committed:解决脏读,但是不可重复读和虚度有可能发生(Oracle用这种)
+   Repeatable read:解决脏读和不可重复读,但是虚读有可能发生(MySQL用这种)
+   Serializable:解决所有问题,但是效率低

#   Hibernate设置隔离级别
##  四种隔离级别对应的数字
+   Read uncommitted ---- 1
+   Read committed ---- 2
+   Repeatable read ---- 4
+   Serializable ---- 8

##  设置隔离级别
```xml
<!-- 如下,设置事务隔离级别 -->
<!-- 设置事务隔离级别 -->
<property name="hibernate.connection.isolation">4</property>

<!-- hibernate.cfg.xml文件的全部内容 -->
<!-- 用以确定 事务隔离级别 在该文件中要写在哪里 -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-configuration PUBLIC
	"-//Hibernate/Hibernate Configuration DTD 3.0//EN"
	"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">

<hibernate-configuration>
	<session-factory>
		<!-- 连接数据库的基本参数 -->
		<property name="hibernate.connection.driver_class">com.mysql.jdbc.Driver</property>
		<property name="hibernate.connection.url">jdbc:mysql://localhost:3306/hibernate</property>
		<property name="hibernate.connection.username">root</property>
		<property name="hibernate.connection.password">root</property>
		<!-- 配置Hibernate的方言 -->
		<property name="hibernate.dialect">org.hibernate.dialect.MySQLDialect</property>
		<!-- 是否显示sql   -->
		<property name="hibernate.show_sql">true</property>
		<!-- 是否格式化sql -->
		<property name="hibernate.format_sql">true</property>
		<!-- 是否使用注释  -->
		<property name="hibernate.use_sql_comments">true</property>

		<!-- 设置事务隔离级别 -->
		<property name="hibernate.connection.isolation">4</property>

		<!-- 映射规则文件 -->
		<mapping resource="com/zjinc36/hibernate/Customer.hbm.xml" />
	</session-factory>
</hibernate-configuration>
```

#   将事务加在Service层
##  为什么需要把事务加在业务层
1.  Dao中封装的是对数据源的单个操作(进行一次CURD)
2.  Service中封装业务逻辑操作,一个业务逻辑往往需要对数据源操作多次
3.  由于一个Service 会调用多个Dao，为了保证这些调用的原子性，事务都是放到Service层的；
4.  若是放到Dao层的话，那么Service里调用的其他的Dao无法保证与前面已经调用的Dao在同一个事务中

##  保证在同一个事务是什么意思
1.  在jdbc要保证connection是同一个
2.  在hibernate中要保证session是同一个

##  在Service层中如何保证在同一个事物
[_参考:https://blog.csdn.net/tanghui270270/article/details/88427076_](https://blog.csdn.net/tanghui270270/article/details/88427076)
+   方法一:将connection向下传递(DBUtils就是这样做的)
+   方法二:使用ThreadLocal对象(Hibernate有封装)
>   [_ThreadLocal说明:https://juejin.im/post/5ac2eb52518825555e5e06ee_](https://juejin.im/post/5ac2eb52518825555e5e06ee)
>   简而言之:往ThreadLocal中填充的变量属于当前线程，该变量对其他线程而言是隔离的,实现了线程的数据隔离

由此可以知道我们只需要做如下两件事
1.  将这个连接绑定到当前线程中
2.  在DAO的方法中,通过当前的线程获得到连接对象

## Hibernate框架如何使用封装好的ThreadLocal
1.  在SessionFactory中提供一个方法getCurrentSeesion()
2.  要开启这个方法,需要通过一个配置完成

### 改写工具类
```java
package com.zjinc36.utils;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

/**
 * Hiberante的工具类
 * @author zjc
 *
 */
public class HibernateUtils {
	public static final Configuration cfg;
	public static final SessionFactory sf;

	static {
		cfg = new Configuration().configure();
		sf = cfg.buildSessionFactory();
	}

	public static Session openSession() {
		return sf.openSession();
	}

	public static Session getCurrentSession() {
		return sf.getCurrentSession();
	}
}
```

### 配置
```xml
<!-- 配置当前线程绑定Session -->
<property name="hibernate.current_session_context_class">thread</property>

<!-- 具体在hibernate.cfg.xml文件中的位置 -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-configuration PUBLIC
	"-//Hibernate/Hibernate Configuration DTD 3.0//EN"
	"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">

<hibernate-configuration>
	<session-factory>
		<!-- 连接数据库的基本参数 -->
		<property name="hibernate.connection.driver_class">com.mysql.jdbc.Driver</property>
		<property name="hibernate.connection.url">jdbc:mysql://localhost:3306/hibernate</property>
		<property name="hibernate.connection.username">root</property>
		<property name="hibernate.connection.password">root</property>
		<!-- 配置Hibernate的方言 -->
		<property name="hibernate.dialect">org.hibernate.dialect.MySQLDialect</property>
		<!-- 是否显示sql   -->
		<property name="hibernate.show_sql">true</property>
		<!-- 是否格式化sql -->
		<property name="hibernate.format_sql">true</property>
		<!-- 是否使用注释  -->
		<property name="hibernate.use_sql_comments">true</property>
		<!-- 设置事务隔离级别 -->
		<property name="hibernate.connection.isolation">4</property>

		<!-- 配置当前线程绑定Session -->
		<property name="hibernate.current_session_context_class">thread</property>

		<!-- 映射规则文件 -->
		<mapping resource="com/zjinc36/hibernate/Customer.hbm.xml" />
	</session-factory>
</hibernate-configuration>
```

### 使用
```java
	@Test
	public void demo6() {
		Session session = HibernateUtils.getCurrentSession();
		Transaction tx = session.beginTransaction();

		Customer customer = new Customer();
		customer.setCust_name("张飞");
		session.save(customer);

		tx.commit();
		// session不用关闭
		// 因为使用getCurrentSession()时,线程结束会自动关闭
	}
```
