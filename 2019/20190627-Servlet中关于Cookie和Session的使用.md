#   Servlet中关于Cookie和Session的使用
date: 2019-06-27 23:43:11
description: 关于Cookie和Session的使用
tags:
- Servlet
categories:
- Java
---
#  Cookie
##  什么是Cookie
>   饼干,其实就是一小份数据,是服务器给客户端,并且存储在客户端上的一份小数据

##  应用场景
>   自动登录,浏览记录,购物车等

##  为什么要使用Cookie
>   http的请求是无状态的.客户端与服务端在通讯的时候,是无状态的,也就是说客户端第二次访问服务端的时候,服务端根本就不知道这个客户端以前是否有来过
>   从用户来讲:为了更好的用户体验,更好的交互[自动登录]
>   从公司来讲:可以更好的收集用户习惯[大数据]

##  Cookie的使用
```java
private void test02(HttpServletRequest req, HttpServletResponse resp)
        throws IOException {
    //获取cookie
    Cookie[] cookies = req.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            System.out.println(cookie.getName() + "=" + cookie.getValue());
        }
    }

    //新建cookie
    Cookie cookie = new Cookie("name", "zhangsan");
    //将cookie传给客户端
    resp.addCookie(cookie);
    //给cookie添加有效期
    //设置expiry的值
    //正值 -> 表示在这个数字之后,cookie将会失败
    //负值 -> 表示关闭浏览器,那么cookie就失效,默认值是-1
    //没有设置有效期 -> 关闭浏览器后,cookie就没有了
    cookie.setMaxAge(60 * 60 * 24 * 7);

    //给cookie赋新的值
    cookie.setValue("lisi");
    //用于指定只有请求了指定的域名,才会带上该cookie
    cookie.setDomain(".address.com");
    //只有访问该域名下的cookieDemo的这个路径才会带cookie
    cookie.setPath("/CookieDemo");

    resp.getWriter().write("...");
}
```
##  Cookie的安全问题
1.  由于Cookie会保存在客户端上,所以有安全隐患
2.  cookie的大小与个数有限制

#   Session
>   会话,Session是基于Cookie的一种会话机制
>   Cookie是服务器返回一小份数据给客户端,并且存放在客户端
>   Session是将数据存放在服务端

##  Session的生命周期
### 创建
>   如果在Servlet里面调用了request.getSession()

### 销毁
>   Session是存放在服务器的内存中的一份数据,当然可以持久话,即使关了浏览器session也不会销毁

1.  关闭服务器
2.  session会话过期时间默认30分钟,有效期过了,也就销毁了

##  Session常用API
```java
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		HttpSession session = req.getSession();
		//得到会话id
		String id = session.getId();
		//存值
		session.setAttribute("name", "value");
		//取值
		session.getAttribute("name");
		//移除值
		session.removeAttribute("name");
        //销毁会话
        session.invalidate();
	}
```

##  简单的购物车例子
```
顺序:
    商品列表 product_list.jsp
        |
        |
    购物车逻辑 CarServlet.java
        |
        |
    购物车展示页 cart.jsp
        |
        |
    清空购物车逻辑 ClearCartServlet.java
```
```html
<!-- product_list.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<a href="CartServlet?id=0"><h3>Iphone7</h3></a>
	<a href="CartServlet?id=1"><h3>小米</h3></a>
	<a href="CartServlet?id=2"><h3>三星Note8</h3></a>
	<a href="CartServlet?id=3"><h3>魅族7</h3></a>
	<a href="CartServlet?id=4"><h3>华为9</h3></a>
</body>
</html>
```

```java
/**
* CarServlet.java
*/
package com.zjinc36.servlet;

import java.io.IOException;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class CarServlet
 */
public class CartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    /**
     * @see HttpServlet#HttpServlet()
     */
    public CartServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        //1. 获取要添加到购物车的商品id
        int id = Integer.parseInt(request.getParameter("id"));
        String[] names = {"Iphone7", "小米6", "三星Note8", "魅族7", "华为9"};
        //2. 取到id对应的商品名称
        String name = names[id];

        //2. 获取购物车存放东西的session Map<String, Integer>
        HashMap<String, Integer> map = (HashMap<String, Integer>) request.getSession().getAttribute("cart");
        //session里面没有存放任何东西
        if (map == null) {
            map = new HashMap<String, Integer>();
            request.getSession().setAttribute("cart", map);
        }
        //3. 判断购物车里面有没有该商品
        if (map.containsKey(name)) {
            // 在原来的值基础上 + 1
            map.put(name, map.get(name) + 1);
        } else {
            map.put(name, 1);
        }

        //4. 输出界面
        response.getWriter().write("<a href='product_list.jsp'><h3>继续购物</h3></a>");
        response.getWriter().write("<a href='cart.jsp'><h3>去购物车结算</h3></a>");
    }
}

```
```html
<!-- cart.jsp -->
<%@page import="java.util.HashMap"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>您的购物车</title>
</head>
<body>
	<h2>您的购物车的商品如下:</h2>
	<%
		//1. 先获取到map
		HashMap<String, Integer> map = (HashMap<String, Integer>)session.getAttribute("cart");

		//2. 遍历map
		if (map != null) {
			for(String key : map.keySet()) {
				int value = map.get(key);
	%>
				<h3>名称:<%=key %>----数量<%=value %></h3><br>
	<%
			}
		}
	%>

	<a href="ClearCartServlet"><h4>清空购物车</h4></a>
</body>
</html>
```
```java
package com.zjinc36.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class ClearCartServlet
 */
public class ClearCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#HttpServlet()
     */
    public ClearCartServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        // 方法一
        // 会话还在,数据清除了
        session.removeAttribute("cart");
        // 方法二
        // 会话直接就没了
        //session.invalidate();
        response.sendRedirect("cart.jsp");
    }
}
```
