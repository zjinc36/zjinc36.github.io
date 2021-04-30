---
title: Hibernate入门与配置
date: 2019-07-02 00:25:13
description: Hibernate入门与配置
categories:
- Java
tags:
- Hibernate
---
#  Hibernate在项目中的位置
EE的三层结构
```
    客户端层 -> JavaApplet/Html/CSS/JS
        |
        |
      Web层 -> Servlet/JSP -> Structs2/Springmvc
        |
        |
    业务逻辑层 -> JavaBean -> Spring
        |
        |
      持久层 -> JDBC -> Hibernate/Mybatis
        |
        |
      数据库
```
Servlet+JSP+JavaBean+JDBC使用这套架构可以开发市面上所有应用,但是企业中不会使用(过于底层)
企业开发一般使用SSH(Struts+Spring+Hibernate),SSM(SpringMVC+Spring+Mybatis)

#  Hibernate的入门案例
## 下载Hibernate和log4j
[hibernate:https://hibernate.org/orm/](https://hibernate.org/orm/)
[log4j:https://logging.apache.org/log4j/1.2/download.html](https://logging.apache.org/log4j/1.2/download.html)

##  创建一个项目导入jar包
### 核心包
将`hibernate-release-5.4.3.Final/lib/required`中的所有文件复制到`eclipse`
### 日志包
将`log4j-1.2-api-2.12.0.jar`和`log4j-to-slf4j-2.12.0.jar`复制到`eclipse`,用来打印日志

具体参考[https://elfasd.iteye.com/blog/1770847](https://elfasd.iteye.com/blog/1770847)

##  创建表
```SQL
create table `cst_customer` (
    `cust_id` BIGINT(32) NOT NULL AUTO_INCREMENT COMMENT '客户编号(主键)',
    `cust_name` VARCHAR(32) NOT NULL COMMENT '客户名称(公司名称)',
    `cust_source` VARCHAR(32) DEFAULT NULL COMMENT '客户信息来源',
    `cust_industry` VARCHAR(32) DEFAULT NULL COMMENT '客户所属行业',
    `cust_level` VARCHAR(32) DEFAULT NULL COMMENT '客户级别',
    `cust_phone` VARCHAR(64) DEFAULT NULL COMMENT '固定电话',
    `cust_mobile` VARCHAR(16) DEFAULT NULL COMMENT '移动电话',
    PRIMARY KEY(`cust_id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8
```
##  创建实体类
```java
package com.zjinc36.hibernate;

/**
 * 客户管理的实体类
 * @author zjc
 */
public class Customer {
	private Long cust_id;
	private String cust_name;
	private String cust_source;
	private String cust_industry;
	private String cust_level;
	private String cust_phone;
	private String cust_mobile;
	public Long getCust_id() {
		return cust_id;
	}
	public void setCust_id(Long cust_id) {
		this.cust_id = cust_id;
	}
	public String getCust_name() {
		return cust_name;
	}
	public void setCust_name(String cust_name) {
		this.cust_name = cust_name;
	}
	public String getCust_source() {
		return cust_source;
	}
	public void setCust_source(String cust_source) {
		this.cust_source = cust_source;
	}
	public String getCust_industry() {
		return cust_industry;
	}
	public void setCust_industry(String cust_industry) {
		this.cust_industry = cust_industry;
	}
	public String getCust_level() {
		return cust_level;
	}
	public void setCust_level(String cust_level) {
		this.cust_level = cust_level;
	}
	public String getCust_phone() {
		return cust_phone;
	}
	public void setCust_phone(String cust_phone) {
		this.cust_phone = cust_phone;
	}
	public String getCust_mobile() {
		return cust_mobile;
	}
	public void setCust_mobile(String cust_mobile) {
		this.cust_mobile = cust_mobile;
	}
}
```
##  创建映射
映射需要通过xml的配置文件完成,这个配置文件可以任意命名,但要尽量做到统一的命名规范,比如`类名.hbm.xml`这样,文件和对应类放在同一层级目录
```xml
<!-- 创建Customer.hbm.xml文件,在和类相同的目录下 -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-mapping PUBLIC
    "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
    "http://www.hibernate.org/dtd/hibernate-mapping-3.0.dtd">
<!-- 根标签 -->
<hibernate-mapping>
	<!-- 建立类与表的映射 -->
	<!-- name对应类名,table对应表名 -->
	<class name="com.zjinc36.hibernate.Customer" table="cst_customer">
		<!-- 建立类中的属性和表中的主键对应 -->
		<!-- name对应类中的属性,column对应表中的字段 -->
		<id name="cust_id" column="cust_id">
			<generator class="native" />
		</id>

		<!-- 建立类中的普通的属性和表的字段的对应 -->
		<property name="cust_name" column="cust_name" />
		<property name="cust_source" column="cust_source" />
		<property name="cust_industry" column="cust_industry" />
		<property name="cust_level" column="cust_level" />
		<property name="cust_phone" column="cust_phone" />
		<property name="cust_mobile" column="cust_mobile" />
	</class>
</hibernate-mapping>
```

##  创建一个Hibernate的核心文件
Hibernate的核心文件`hibernate.cfg.xml`,用以设置数据库,设置映射文件等,放在src根目录下
```xml
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
		<!-- 映射规则文件 -->
		<mapping resource="com/zjinc36/hibernate/Customer.hbm.xml" />
	</session-factory>
</hibernate-configuration>
```

##  使用Hiberante向表中插入数据
```java
package com.zjinc36.hibernate;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.junit.Test;

/**
 * Hibernate入门案例
 * @author zjc
 *
 */
public class HibernateDemo1 {
	@Test
	// 保存客户的案例
	public void demo1() {
		// 1. 加载Hibernate的核心配置文件
		// 其实就是加载一个常量DEFAULT_CFG_RESOURCE_NAME=hibernate.cfg.xml
		// 这也就是为什么Hibernate的核心配置文件命名为hibernate.cfg.xml的原因
		// 同时也是为什么我们说这个配置文件的名字可以改,但我们一般不改的原因
		Configuration configuration = new Configuration().configure();
		// 2. 创建一个SessionFactory对象,类似于JDBC连接池
		SessionFactory sessionFactory = configuration.buildSessionFactory();
		// 3. 通过SessionFactory获取到Session对象Connection
		Session session = sessionFactory.openSession();
		// 4. 手动开启事务
		Transaction transaction = session.beginTransaction();
		// 5. 编写代码
		Customer customer = new Customer();
		customer.setCust_name("zhangsan");
		session.save(customer);
		// 6. 提交事务
		transaction.commit();
		// 7. 释放资源
		session.close();
	}
}
```

# 在Eclipse中导入dtd和xsd文件，使XML自动提示
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

#   Hibernate的映射的配置
##  class标签
用来建立类与表的映射关系
+   name:类的全路径
+   table:表名(类名与表名一致,那么table可以省略)
+   catalog:数据库名
##  id标签
用来建立类中的属性与表中的主键的对应关系
+   name:类中的属性名
+   column:表中的字段名(类中的属性名和表中的字段名一致,那么column可以省略)
+   length:长度
+   type:类型(有三种方式,分别是java写法,hibernate写法,sql写法)
##  property标签的配置
+   name:类中的属性名
+   column:表中的字段名
+   length:长度
+   type:类型
+   not-null:设置非空
+   unique:设置唯一

#   Hibernate的核心配置
有两种配置方式
+   属性文件的方式(了解,可以跳过)
>   hibernate.properties文件
>   +   hibernate.connection.driver_class=com.mysql.jdbc.Driver
>   +   hibernate.show_sql=true
>   属性文件的方式不能引入映射文件(需要手动编写代码加载映射文件,所以这种方法不常用)
+   XML文件的方式
>   hibernate.cfg.xml
##  xml配置方式详解
### 连接数据库的基本参数
+   驱动类
+   url路径
+   用户名
+   密码
### 方言

##  可选的配置
### 显示SQL
>   显示SQL:`hibernate.show_sql`
### 格式化SQL
>   格式化SQL:`hibernate.format_sql`
### 自动建表
####    自动建表
>   自动建表:`<property name="hibernate.hbm2ddl.auto">update</property>`
>   +   none:不使用hibernate的自动建表
>   +   create:如果数据库中已经有表,删除原有表,重新创建,如果没有表,新建表(测试常用)
>   +   create-drop:如果数据库中已经有表,删除原有表,执行奥做,删除这个表.如果没有表,新建一个,使用完了删除该表(测试常用)
>   +   update:如果数据库中有表,使用原有表.如果没有表,创建新表(更新表结构)
>   +   validate:如果没有表,不会创建表,只会使用数据库中原有的表(校验映射和表结构)
####    问题:表可以删除,却无法自动创建
>   [_参考:https://blog.csdn.net/weixin_40327259/article/details/80803754_](https://blog.csdn.net/weixin_40327259/article/details/80803754)

**原因**
hibernate里的dialect和Mysql的版本不匹配,SQL语句,在MySQL5.0之前是设置表类型type="..."，5.0之后是使用engine="..."设置表类型

**解决**
```xml
<!-- MySql5.0之前的配置 -->
<property name="dialect">org.hibernate.dialect.MySQLDialect</property>

<!-- MySql5.0之后的配置 -->
<property name="dialect">org.hibernate.dialect.MySQL5Dialect</property>
```

##  映射文件引入
>  引入映射文件的位置`<mapping resource="com/zjinc36/hibernate/Customer.hbm.xml" />`

