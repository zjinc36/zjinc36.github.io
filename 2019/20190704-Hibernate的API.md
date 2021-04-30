---
title: Hibernate的API
date: 2019-07-04 14:19:31
description: Hibernate的API
categories:
- Java
tags:
- Hibernate
---
#   Configuration
##  作用
用以加载核心配置文件
##  加载方式
####    方式一:文件名是`hibernate.properties`(了解居多)
```java
Configuration cfg = new Configuration();
```
####    方式二:文件名是`hibernate.cfg.xml`
```java
Configuration cfg = new Configuration().configure();

//如果不是默认的文件名,还需要如下语句
//cfg.addResource("com/zjinc36/hibernate/Customer.hbm.xml")

```
#   SessionFactory
##  简介
SessionFactory内部维护了Hibernate的连接池和Hibernate的二级缓存(不讲)
是线程安全的对象
一个项目创建一个对象即可
[参考:https://blog.csdn.net/fan71900/article/details/45890915](https://blog.csdn.net/fan71900/article/details/45890915)
##  配置
1.  引入jar包,将`hibernate-release-5.4.3.Final/lib/optional/c3p0`下的所有jar包导入项目中
2.  在核心配置文件中添加如下选项
_参考[https://www.cnblogs.com/caoyc/p/5607051.html](https://www.cnblogs.com/caoyc/p/5607051.html)_
```xml
<!-- 数据库连接池的使用 -->
<!-- 选择使用C3P0连接池 -->
<property name="hibernate.connection.provider_class">org.hibernate.c3p0.internal.C3P0ConnectionProvider</property>
<!-- 连接池中最小连接数 -->
<property name="hibernate.c3p0.min_size">5</property>
<!-- 连接池中最大连接数 -->
<property name="hibernate.c3p0.max_size">20</property>
<!-- 设定数据库连接超时时间，以秒为单位。如果连接池中某个数据库连接处于空闲状态且超过timeout秒时，就会从连接池中移除-->
<property name="hibernate.c3p0.timeout">120</property>
<!-- 设置数据库 -->
<property name="hibernate.c3p0.idle_test_period">3000</property>
```
##  抽取工具类
目的是为了保证一个项目只创建一个SessionFactory对象
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
}

```

#   Session
##  简介
Session代表的是Hibernate与数据库的连接对象,即与数据库交互桥梁
不是线程安全

##  Session中的API
###	保存操作
+	Serializable save(Object obj)`
```java
	@Test
	//测试save保存
	//返回id
	public void saveDemo() {
		Session session = HibernateUtils.openSession();
		Transaction tx = session.beginTransaction();

		Customer customer = new Customer();
		customer.setCust_name("lisi");
		Serializable id = session.save(customer);
		System.out.println(id);

		tx.commit();
		session.close();
	}
```

###	查询操作
**注意get和load方法的区别(代码中的注释)**

*   T get(Class c,Serializable id);
```java
	@Test
	// 测试get查询方法
	// 采用的是立即加载,执行到get的时候,就会马上发送SQL语句去查询
	// 查询后返回的是真实对象
	// 查询一个找不到的对象的时候,返回null
	public void getDemo() {
		Session session = HibernateUtils.openSession();
		Transaction tx = session.beginTransaction();

		Customer customer = session.get(Customer.class, 1L);
		System.out.println(customer);

		tx.commit();
		session.close();
	}
```
+   T load(Class, c,Serializable id);
```java
	@Test
	// 测试load查询方法
	// 采用的是延迟加载(lazy懒加载),执行到这行代码的时候,不会发送SQL语句,当真正使用这个对象的时候才会发送SQL语句
	// 查询后返回的是代理对象,利用`javassist-3.24.0-GA.jar`技术来产生代理
	// 查询一个找不到的对象的时候,返回ObjectNotFoundException
	public void loadDemo() {
		Session session = HibernateUtils.openSession();
		Transaction tx = session.beginTransaction();

		Customer customer = session.load(Customer.class, 6L);
		System.out.println(customer);

		tx.commit();
		session.close();
	}
```

### 更新操作
+   void update(Object obj);
```java
	@Test
	/**
	 * 更新操作
	 */
	public void updateDemo() {
		Session session = HibernateUtils.openSession();
		Transaction tx = session.beginTransaction();

		// 不推荐
		// 直接创建对象,进行修改
//		Customer customer = new Customer();
//		customer.setCust_id(1L);
//		customer.setCust_name("wangwu");
//		session.update(customer);

		// 推荐
		// 先查询,再修改
		Customer customer = session.get(Customer.class, 6L);
		customer.setCust_name("wangwu");
		session.update(customer);

		tx.commit();
		session.close();
	}
```

### 删除操作
+   void delete(Object obj);
```java
	@Test
	/**
	 * 删除操作
	 */
	public void deleteDemo() {
		Session session = HibernateUtils.openSession();
		Transaction tx = session.beginTransaction();

		// 不推荐
		// 直接创建对象,进行删除
//		Customer customer = new Customer();
//		customer.setCust_id(1L);
//		session.delete(customer);

		// 推荐
		// 先查询,再修改
		// 级联删除
		Customer customer = session.get(Customer.class, 6L);
		session.delete(customer);

		tx.commit();
		session.close();
	}
```

### 保存或更新操作
+   void saveOrUpdate(Object obj);
```java
	@Test
	/**
	 * 保存或更新
	 */
	public void saveOrUpdateDemo() {
		Session session = HibernateUtils.openSession();
		Transaction tx = session.beginTransaction();

		Customer customer = new Customer();
		customer.setCust_id(10L);
		customer.setCust_name("abc");
		session.saveOrUpdate(customer);

		tx.commit();
		session.close();
	}
```

### 查询所有操作
```java
	@Test
	/**
	 * 查询所有
	 */
	public void findAllDemo() {
		Session session = HibernateUtils.openSession();
		Transaction tx = session.beginTransaction();

		// 接收HQL:Hibernate Query Language 面向对象的查询语句
//		Query<Customer> query = session.createQuery("from Customer");
//		List<Customer> list = query.list();
//		for (Customer customer : list) {
//			System.out.println(customer);
//		}

		// 接受SQL
		SQLQuery<Object[]> query = session.createSQLQuery("select * from cst_customer");
		List<Object[]> list = query.list();
		for (Object[] objects : list) {
			System.out.println(Arrays.toString(objects));
		}

		tx.commit();
		session.close();
	}
```

#   Transaction
事务对象,详见本博客的其他文章[Hibernate事务管理](/2019/07/08/Hibernate事务管理/)
+   commit()
+   roallback()

#   Query
***具体查看本博客的:[Hibernate的查询方式](/2019/07/09/Hibernate的查询方式)***
##  HQL
`Hibernate Query Language`,Hibernate查询语言,这种语言和SQL极其类似,面向对象的查询语句
### 简单的查询
```java
	@Test
	/**
	 * 简单的查询
	 */
	public void demo1() {
		Session session = HibernateUtils.getCurrentSession();
		Transaction tx = session.beginTransaction();

		// 通过session获得Query接口
		// 注意这里的Customer指的是类
		// 查询语句
		String hql = "from Customer where cust_name like ?0";
		Query query = session.createQuery(hql);
		// 设置条件(如果查询语句不需要条件,该句可省略)
		query.setParameter(0, "zhang%");
		List<Customer> list = query.getResultList();
		for (Customer customer : list) {
			System.out.println(customer);
		}
		tx.commit();
	}
```

### 分页查询
```java
	@Test
	/**
	 * 分页查询
	 */
	public void demo2() {
		Session session = HibernateUtils.getCurrentSession();
		Transaction tx = session.beginTransaction();

		// 通过session获得Query接口
		// 注意这里的Customer指的是类
		// 查询语句
		String hql = "from Customer";
		Query query = session.createQuery(hql);
		// 设置分页
		query.setFirstResult(0);
		query.setMaxResults(3);
		List<Customer> list = query.getResultList();
		for (Customer customer : list) {
			System.out.println(customer);
		}
		tx.commit();
	}
```

##  QBC
QBC -> Query by Criteria,更加面向对象的一种查询方式
### 简单查询
```java
	@Test
	/**
	 * Criteria
	 */
	public void demo3() {
		Session session = HibernateUtils.getCurrentSession();
		Transaction tx = session.beginTransaction();

		// 写具体逻辑crud(增删改查)操作

		// 1创建Criteria对象 createCriteria()在hibernate5.2之后过时了
//		Criteria criteria = session.createCriteria(Customer.class);
//		List<Customer> list = criteria.list();
//		for (Student customer : list) {
//			System.out.println(customer);
//		}

		// 新的查询方式
		// 1.创建CriteriaBuilder对象
		// 注意导入的包是import javax.persistence.criteria.CriteriaQuery;
		CriteriaBuilder criteriaBuilder = session.getCriteriaBuilder();
		// 2.获取CriteriaQuery对象
		CriteriaQuery<Customer> createQuery = criteriaBuilder.createQuery(Customer.class);
		// 3.指定根条件
		createQuery.from(Customer.class);
		// 4执行查询
		List<Customer> List = session.createQuery(createQuery).getResultList();

		for (Customer customer : List) {
			System.err.println(customer);
		}

		tx.commit();
	}
```

###	模糊查询
```java
	/**
	 *	模糊查询
	 */
	@Test
	public void demo4() {
		//获取session对象
		Session session = HibernateUtils.getCurrentSession();
		//开启事务
		Transaction tx = session.beginTransaction();

		//写具体逻辑crud(增删改查)操作

//		//创建Criteria对象 createCriteria()在hibernate5.2之后过时了
//		Criteria criteria = session.createCriteria(Customer.class);
//		criteria.add(Restrictions.like("cust_name", "zhang%"));
//		List<Customer> list = criteria.list();
//		for (Student customer : list) {
//			System.out.println(customer);
//		}

		//新的查询方式
		//1.创建CriteriaBuilder对象
		//注意导入的包是import javax.persistence.criteria.CriteriaQuery;
		CriteriaBuilder criteriaBuilder = session.getCriteriaBuilder();
		//2.获取CriteriaQuery对象
		CriteriaQuery<Customer> createQuery = criteriaBuilder.createQuery(Customer.class);
		//3.指定根条件
		Root<Customer> root = createQuery.from(Customer.class);
		//root.get("name") "name"是实体类的属性名称
		createQuery.where(criteriaBuilder.like(root.get("cust_name"), "%zhang%"));
		//4.执行查询
		List<Customer> List = session.createQuery(createQuery).getResultList();

		for (Customer customer : List) {
			System.err.println(customer);
		}

		//提交事务
		tx.commit();
	}
```

##  SQLQuery
用于接收SQL,特别复杂情况下使用SQL
