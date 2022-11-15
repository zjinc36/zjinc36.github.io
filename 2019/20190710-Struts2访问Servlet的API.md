# Struts2访问Servlet的API

---

# Servlet 和 Action 的区别

>	[_参考:https://blog.csdn.net/siwuxie095/article/details/77075528_](https://blog.csdn.net/siwuxie095/article/details/77075528)
>	Servlet：默认在第一次访问时创建，且只创建一次，是单实例对象
>	Action：访问时创建，且每次访问都会创建，创建多次，是多实例对象

# Struts2访问Servlet的API的方式

## 完全解耦合的方式

### 1.入口

```html
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>Struts访问Servlet的API</h1>
	<h3>方式一:完全解耦合的方式</h3>
	<form action="${ pageContext.request.contextPath }/requestDemo1.action" method="post">
		姓名:<input type="text" name="name" /><br/>
		密码:<input type="password" name="password" /><br/>
		<input type="submit" value="提交" />
	</form>
</body>
</html>
```

### 2.Action

```java
package com.zjinc36.demo3;

import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionSupport;

public class requestDemo1 extends ActionSupport {
	@Override
	public String execute() throws Exception {
		// 接受参数
		// 利用Struts2中的对象
		ActionContext context = ActionContext.getContext();
		// 调用ActionContext中的方法
		// 类似于request.getParameterMap()
		Map<String, Object> map = context.getParameters();
		Set<String> keySet = map.keySet();
		for (Iterator iterator = keySet.iterator(); iterator.hasNext();) {
			String key = (String) iterator.next();
			String[] value = (String[]) map.get(key);
			System.out.println(key + "----" + Arrays.toString(value));
		}

		//向域对象中存入数据
		context.put("reqName", "reqValue");	//相当于request.setAttribute()
		context.getSession().put("sessName", "sessValue");	//相当于session.setAttribute()
		context.getApplication().put("appName", "appValue");	//相当于application.setAttribute()
		return SUCCESS;
	}
}
```

### 3.映射

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE struts PUBLIC
	"-//Apache Software Foundation//DTD Struts Configuration 2.3//EN"
	"http://struts.apache.org/dtds/struts-2.3.dtd">
<struts>
	<package name="demo3" extends="struts-default" namespace="/">
		<action name="requestDemo1" class="com.zjinc36.demo3.requestDemo1">
			<result name="success">success.jsp</result>
		</action>
	</package>
</struts>
```

### 4.出口

```html
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>Struts访问Servlet的API</h1>
	<h3>方式一:完全解耦合的方式</h3>
	<form action="${ pageContext.request.contextPath }/requestDemo1.action" method="post">
		姓名:<input type="text" name="name" /><br/>
		密码:<input type="password" name="password" /><br/>
		<input type="submit" value="提交" />
	</form>
</body>
</html>
```

### 需要注意

**注:这种方式只能获得代表request,session,application的数据的Map集合,不能操作这些对象本身的方法**

## 使用servlet原生的api方式

### Action

```java
package com.zjinc36.demo3;

import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.struts2.ServletActionContext;

import com.opensymphony.xwork2.ActionSupport;

public class requestDemo2 extends ActionSupport {
	@Override
	public String execute() throws Exception {
		// 1.接受数据
		// 直接获得request对象,通过ServletActionContext
		HttpServletRequest request = ServletActionContext.getRequest();
		Map<String, String[]> map = request.getParameterMap();
		Set<String> keys = map.keySet();
		for (Iterator iterator = keys.iterator(); iterator.hasNext();) {
			String key = (String) iterator.next();
			String[] value = map.get(key);
			System.out.println(key + "----" + Arrays.toString(value));
		}
		// 2.向域对象中保存数据
		request.setAttribute("reqName", "reqValue");
		request.getSession().setAttribute("sessName", "sessValue");
		ServletActionContext.getServletContext().setAttribute("appName", "appValue");
		return SUCCESS;
	}
}
```
### 需要注意

**这种方式既可以操作域对象的数据,也可以获得对象的方法**

## 接口注入方式

### Action

```java
package com.zjinc36.demo3;

import java.util.Arrays;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextAttributeListener;
import javax.servlet.http.HttpServletRequest;

import org.apache.struts2.interceptor.ServletRequestAware;
import org.apache.struts2.util.ServletContextAware;

import com.opensymphony.xwork2.ActionSupport;


public class requestDemo3 extends ActionSupport implements ServletRequestAware, ServletContextAware{
	private HttpServletRequest request;
	private ServletContext context;
	@Override
	public String execute() throws Exception {
		// 1.接受参数
		// 通过接口注入的方式获得request
		Map<String, String[]> map = request.getParameterMap();
		Set<String> keys = map.keySet();
		for (Iterator iterator = keys.iterator(); iterator.hasNext();) {
			String key = (String) iterator.next();
			String[] value = map.get(key);
			System.out.println(key + "----" + Arrays.toString(value));
		}

		//2.向域对象中保存数据
		request.setAttribute("reqName", "reqValue");
		request.getSession().setAttribute("sessName", "sessValue");
		context.setAttribute("appName", "appValue");
		return super.execute();
	}

	@Override
	public void setServletContext(ServletContext context) {
		this.context = context;
	}
	@Override
	public void setServletRequest(HttpServletRequest request) {
		this.request = request;
	}
}
```

### 注意

Servlet是单例的,多个程序访问一个Servlet只会创建一个Servlet实例.而这里的Action是多例的,一次请求,创建一个Action的实例,不会出现线程安全的问题
