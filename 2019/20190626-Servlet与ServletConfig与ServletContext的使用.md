---
title: Servlet与ServletConfig与ServletContext的使用
date: 2019-06-26 09:16:47
description: Servlet的介绍,ServletConfig,ServletContext
tags:
- Servlet
categories:
- Java
---
##  Servlet是什么?
>   其实就是一个java程序,运行在我们的web服务器上,用于接收和响应客户端的http请求
>   更多的是配合动态资源来做,当然静态资源也需要使用到Servlet,只不过是Tomcat里面已经定义好了一个 DefaultServlet

##  Hello Servlet
1.  写一个web工程,要有一个服务器 -> 参见`Eclipse配置Tomcat`
2.  测试运行web工程
3.  在`Java Resource/src`下新建一个类,实现Servlet接口
```java
package com.itheima.servlet;

import java.io.IOException;

import javax.servlet.Servlet;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

public class HelloServlet implements Servlet {
	@Override
	public void destroy() {
	}
	@Override
	public ServletConfig getServletConfig() {
		return null;
	}

	@Override
	public String getServletInfo() {
		return null;
	}

	@Override
	public void init(ServletConfig config) throws ServletException {
	}

	@Override
	public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException {
		System.out.println("Hello");
	}

}
```
4.  配置Servlet,用于告诉服务器,我们的应用有这么个Servlet
```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://java.sun.com/xml/ns/javaee" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" id="WebApp_ID" version="2.5">
  <display-name>HelloWeb</display-name>
  <welcome-file-list>
    <welcome-file>index.html</welcome-file>
    <welcome-file>index.htm</welcome-file>
    <welcome-file>index.jsp</welcome-file>
    <welcome-file>default.html</welcome-file>
    <welcome-file>default.htm</welcome-file>
    <welcome-file>default.jsp</welcome-file>
  </welcome-file-list>

  <!-- 向tomcat报告,我这个应用里面有这个servlet,名字和具体路径 -->
  <servlet>
  	<!-- 名字 -->
  	<servlet-name>HelloServlet</servlet-name>
  	<!-- 具体路径 -->
  	<servlet-class>com.itheima.servlet.HelloServlet</servlet-class>
  </servlet>

  <!-- 注册servlet映射 servletName:找到上面注册的具体servlet url-pattern:在地址栏上的path -->
  <servlet-mapping>
  	<servlet-name>HelloServlet</servlet-name>
  	<url-pattern>/a</url-pattern>
  </servlet-mapping>
</web-app>
```

##  Servlet执行过程
1.  找到Tomcat应用
2.  找到项目
3.  找`web.xml`,然后在web.xml里面找到`url-pattern`,有没有哪一个`pattern`的内容是`/a`
4.  找到`servlet-mapping`中的那个`servlet-name` -> [HelloServlet]
5.  根据`servlet-name`找到`servlet`元素中的`servlet-name`中的[HelloServlet]
6.  找到`对应的class`,然后开始创建该类的请求实例
7.  执行对应class中的`service`方法


##  Servlet的通用写法
```
    Servlet(接口)
        |
        |
    GenericServlet
        |
        |
    HttpServlet(用于处理http的请求)
```

##  Servlet生命周期
###    什么是生命周期
>   从创建到销毁的一段时间

###    生命周期方法
>   从创建到销毁,所调用的那些方法
####   init方法
```java
	/**
	 * 在创建该Servlet的实例时,就执行该方法
	 * 一个servlet只会初始化一次,init方法只会执行一次
	 * 默认情况下是:初次访问该servlet,才会创建实例
	 */
	@Override
	public void init(ServletConfig config) throws ServletException {
		// TODO Auto-generated method stub

	}
```
####   service方法
```java
	/**
	 * 只要客户端来了一个请求,那么就执行这个方法
	 * 该方法可以被执行很多次,一次请求,对应一次service方法的调用
	 */
	@Override
	public void service(ServletRequest req, ServletResponse res)
			throws ServletException, IOException {
		// TODO Auto-generated method stub

	}
```
####   destroy方法
```java
	/**
	 * servlet销毁的时候,就会执行该方法
	 * 1. 该项目从tomcat
	 * 2. 正常关闭tomcat就会执行(shutdown.bat)
	 */
	@Override
	public void destroy() {
		// TODO Auto-generated method stub

	}
```

### 让Servlet创建实例的时机提前
####    问题提出
默认情况下,只有在初次访问servlet的时候,才会执行init方法.有的时候,我们可能需要在这个方法里面执行一些初始化工作,甚至做一些耗时的逻辑,那么这个时候,初次访问,可能会在init方法中逗留太久的时间.那么有没有方法可以让这个初始化的时机提前一点
####    解决方法
在`web.xml`中配置的时候,使用`<load-on-startup>`元素,给定的数字越小,启动的时机就越早,一般不写负数,从2开始
```xml
  <servlet>
  	<servlet-name>HelloServlet03</servlet-name>
  	<servlet-class>com.itheima.servlet.HelloServlet03</servlet-class>
  	<load-on-startup>3</load-on-startup>
  </servlet>
```

##  使用ServletConfig
### 作用
>   servlet的配置,通过这个对象,可以获取servlet在配置的时候一些信息
### 怎么写
```xml
<!-- web.xml文件中的servlet的配置信息 -->
<servlet>
    <description></description>
    <display-name>HelloServletConfig</display-name>
    <servlet-name>HelloServletConfig</servlet-name>
    <servlet-class>com.itheima.servlet.HelloServletConfig</servlet-class>
    <!-- 可以添加初始化参数 -->
    <!-- 用config.getInitParameter("address");函数获取 -->
    <init-param>
    	<param-name>address</param-name>
    	<param-value>beijing...</param-value>
    </init-param>
</servlet>
<servlet-mapping>
    <servlet-name>HelloServletConfig</servlet-name>
    <url-pattern>/HelloServletConfig</url-pattern>
</servlet-mapping>
```
```java
/**
* 代码片段
* ServletConfig,用以获取上述web.xml文件中对应的servlet配置信息
*/
protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    super.doGet(req, resp);

    //ServletConfig,用以获取上述web.xml文件中对应的servlet配置信息
    //1. 得到servlet配置对象,专门用于在配置中的servlet的信息
    ServletConfig config = getServletConfig();
    //获取到的是配置servlet里面servlet-name的文本内容
    String servletName = config.getServletName();
    System.out.println(servletName);

    //2. 可以获取具体的某一参数
    String address = config.getInitParameter("address");
    System.out.println(address);

    System.out.println("-----------------------------");

    //3. 获取所有的参数名称
    Enumeration<String> names = config.getInitParameterNames();
    //遍历取出所有的参数名称
    while (names.hasMoreElements()) {
        String name = (String) names.nextElement();
        System.out.println("name ===" + name);
    }
}
```

### 为什么需要有这个ServletConfig
1.  未来我们自己开发的一些应用,使用到了一些技术,或者一些代码,我们不会,但是有人写出来了,它的代码放置在了自己的servlet类里面
2.  刚好这个servlet里面需要一个数组或者叫做变量值,但是这个值不是固定的,所以要求使用到这个servlet的工资,在注册servlet的时候,必须要在web.xml里面,声明init-params

##  Servlet配置方式
看代码中的注释
### 全路径匹配
```xml
  <!-- web.xml文件 -->
  <servlet>
    <description></description>
    <display-name>Demo</display-name>
    <servlet-name>Demo</servlet-name>
    <servlet-class>com.zjinc36.servlet.Demo</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>Demo</servlet-name>

    <!-- 以 / 开始,要写的一模一样 -->
    <!-- 即浏览器要输入: http://localhost:8080/项目名称/aa/bb -->
    <url-pattern>/aa/bb</url-pattern>
  </servlet-mapping>
```

### 路径匹配,前半段匹配
```xml
  <!-- web.xml文件 -->
  <servlet>
    <description></description>
    <display-name>Demo</display-name>
    <servlet-name>Demo</servlet-name>
    <servlet-class>com.zjinc36.servlet.Demo</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>Demo</servlet-name>

    <!-- 以 / 开始,但是以 * 结束 -->
    <!-- `*`其实是一个通配符,匹配任意文字 -->
    <!-- localhost:8080/项目名称/aa/bb  <- 这里不限定/aa/bb,可以随意写 -->
    <url-pattern>/*</url-pattern>
  </servlet-mapping>
```

### 以扩展名匹配
```xml
  <!-- web.xml文件 -->
  <servlet>
    <description></description>
    <display-name>Demo</display-name>
    <servlet-name>Demo</servlet-name>
    <servlet-class>com.zjinc36.servlet.Demo</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>Demo</servlet-name>

    <!-- 没有/,以*开始,"*.扩展名" -->
    <!-- `*`其实是一个通配符,匹配任意文字 -->
    <!-- localhost:8080/项目名称/aa/bb/cc.aa  <- 这里不限定/aa/bb,可以随意写,只要结尾以.aa为扩展名就行 -->
    <url-pattern>*.aa</url-pattern>
  </servlet-mapping>
```

##  ServletContext
>   Servlet上下文
>   每个web工程只有一个servletContext对象.也就是说,不管在哪个servlet里面,获取到的这个类的对象都是同一个.

### 有什么作用
#### 可以获取全局配置参数
1.  web.xml文件,注意全局参数的位置
```xml
<!-- web.xml文件 -->

<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://java.sun.com/xml/ns/javaee" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" id="WebApp_ID" version="2.5">
  <display-name>Demo3</display-name>
  <welcome-file-list>
    <welcome-file>index.html</welcome-file>
    <welcome-file>index.htm</welcome-file>
    <welcome-file>index.jsp</welcome-file>
    <welcome-file>default.html</welcome-file>
    <welcome-file>default.htm</welcome-file>
    <welcome-file>default.jsp</welcome-file>
  </welcome-file-list>
  <!-- 配置全局参数 -->
  <!-- 全局参数:哪个Servlet都可以拿 -->
  <context-param>
  	<param-name>address</param-name>
  	<param-value>具体地址</param-value>
  </context-param>
  <servlet>
    <description></description>
    <display-name>Demo3</display-name>
    <servlet-name>Demo3</servlet-name>
    <servlet-class>com.zjinc36.servlet.Demo3</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>Demo3</servlet-name>
    <url-pattern>/Demo3</url-pattern>
  </servlet-mapping>
</web-app>
```

2.  java的代码实现
```java
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		super.doGet(req, resp);

        // 1.获取对象
		ServletContext context = getServletContext();
        // 2.获取对应的参数
		String address = context.getInitParameter("address");
		System.err.println("address=" + address);

	}
```

####    可以获取web应用中的资源
1.  方式一:只取文件,自己手动转流
```java
/**
* 先获取文件,在转换成流对象
*/
private void test01() throws FileNotFoundException, IOException {
    //1.ServletContext对象
    ServletContext context = getServletContext();
    //2.获取给定的文件在服务器上面的绝对路径
    //可以不给参数打印path,就能知道对应的根目录是哪个目录,从而能更清楚的写相对目录
    String path = context.getRealPath("file/config.properties");
    //3.指定载入的数据源
    //此处,如果想要获取web工程下的资源,用普通的FileInputStream写法不是OK的
    //因为路径不对了,这里相对的路径,其实是根据jre来确定的.
    //由于我们这是一个web工程,jre后面会由tomcat管理,所以这里真正相对路径是tomcat里面的bin目录
    //所以我们会用ServletContext对象来获取
    InputStream is = new FileInputStream(path);
    //4.创建属性对象
    Properties properties = new Properties();
    properties.load(is);
    String name = properties.getProperty("name");
    System.out.println("name=" + name);
}
```

2.  方式二:直接将指定文件转化成流对象
```java
/**
* 根据相对路径,直接获取流对象
*/
private void test02() {
    try {
        //1.ServletContext对象
        ServletContext context = getServletContext();
        //2.获取web工程下的资源,转化成流对象,前面隐藏当前工程的根目录
        InputStream is = context.getResourceAsStream("file/config.properties");
        //3.创建属性对象
        Properties properties = new Properties();
        properties.load(is);
        String name = properties.getProperty("name");
        System.out.println("name=" + name);
        is.close();
    } catch (FileNotFoundException e) {
        e.printStackTrace();
    } catch (IOException e) {
        e.printStackTrace();
    }
}
```

3.  方式三:直接将指定文件转化成流对象,**但是不用到ServletContext对象**
```java
/**
* 根据相对路径,直接获取流对象
* 不使用ServletContext对象
*/
private void test03() {
	try {
		//1.获取资源
		//获取java文件的class, 然后获取到加载这个class到虚拟机中的那个类加载器对象
		//此时的根路径在: wtpwebapps/项目名称/WEB-INF/classes
		InputStream is = this.getClass().getClassLoader().getResourceAsStream("../../file/config.properties");
		//2.创建属性对象
		Properties properties = new Properties();
		properties.load(is);
		String name = properties.getProperty("name");
		System.out.println("name=" + name);
		is.close();
	} catch (IOException e) {
		e.printStackTrace();
	}
}
```

####    存取数据,Servlet间共享数据(域对象)
```java
/**
* 使用ServletContext存取数据
*/
protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    //1.获取数据
    String userName = req.getParameter("username");
    String password = req.getParameter("password");
    //2.校验数据,并返回给客户端
    PrintWriter pw = resp.getWriter();
    if ("admin".equals(userName) && "123".equals(password) ) {
        //成功
        //3.保存数据,在多个Servlet之间共享
        //获取ServletContext保存的count的数据
        Object obj = getServletContext().getAttribute("count");
        int totalCount = 0;
        if (obj != null) {
            totalCount = (int)obj;
        }
        System.out.println("已知登录成功的次数是:" + totalCount);
        //向ServletContext的CountServlet写入数据
        getServletContext().setAttribute("count", totalCount + 1);

        //4.设置状态码
        resp.setStatus(302);
        //5.定位跳转的位置是哪一个页面
        resp.setHeader("Location", "login_success.html");
    } else {
        //失败,打印失败数据到网页
        pw.write("login failed...");
    }
}
```
### ServletContext的生命周期
####    何时创建
>   服务器启动的时候,会为托管的每一个web应用程序,创建一个ServletContext对象

####    何时销毁
>   从服务器移除托管,或者是关闭服务器

### ServletContext的作用范围
>   只要在相同项目里面,都可以取.

