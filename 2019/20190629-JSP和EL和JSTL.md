#   JSP和EL和JSTL
date: 2019-06-29 09:49:11
description: JSP和EL和JSTL
tags:
- JSP/EL/JSTL
- Struts2
- Servlet
categories:
- Java
---
#   JSP
##  什么是JSP
`Java Server Page`的缩写
从用户角度看待,就是一个网页
从程序员角度看待,其实是一个java类,它继承了Servlet,所以可以直接说jsp就是一个Servlet

##  为什么会有JSP
html多数情况下用来显示静态内容,一成不变的.但是有时候我们需要在网页上显示一些动态数据
比如:查询所有的学生信息,根据姓名去查询某个学生.
这些动作都需要去查询数据库,然后在网页上显示
html不支持写java代码,jsp里面可以写java代码

##  怎么用JSP
### 指令的写法
```
    <%@ 指令名字 %>
```

### 指令详解
####    page指令
```
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
```
+   language:表明jsp页面中可以写java代码
+   contentType:告诉浏览器我是什么内容类型,以及使用什么编码
+   pageEncoding:jsp内容编码
+   extends:用于指定jsp翻译成java文件后,继承的父类是谁,一般不用改
+   import:导包使用,一般不用手写
+   session:值可选的有true或false,用于控制在这个jsp页面里面,能够直接使用session对象,具体的区别请看翻译后的java文件,如果该值是true,那么在代码里面会有getSession()的调用,如果是false,那么就不会有该方法调用,也就是没有session对象了,在页面也就自然不能使用了
+   errorPage:指的是错误的页面,当当前页面有错误的java代码时,自动跳转到错误页面
+   isErrorPage:上面的errorPage用于指定错误的时候跑到哪一个页面去,而这个isErrorPage,就是声明某一个页面到底是不是错误的页面

####    include指令
```
<%@ include file="other2.jsp" %>
```
本质上就是把另外一个页面的所有内容拿过来一起输出,所有的标签元素都包含进来

####    taglib指令
```
<%@ taglib prefix="" uri="" %>
```
+   uri:标签库路径
+   prefix:标签库的别名

##  JSP动作标签
```
<jsp:include page=""></jsp:include>
<jsp:param value="" name="" />
<jsp:forward page=""></jsp:forward>
```
+   jsp:include
>   包含指定页面,这里是动态包含,也就是不把包含的页面所有元素标签全部拿过来输出,而是把它运行结果拿过来
+   jsp:forward
>   前往哪一个页面
>   相当于`<% request.getRequestDispatcher("other02.jsp").forward(request, response); %>`
+   jsp:param
>   在包含某个页面的时候,或者在跳转某个页面的时候,带个参数

```jsp
other01.jsp页面:

<jsp:forward page="other02.jsp">
    <jsp:param value="beijing" name="address" />
</jsp:forward>>

ohter02.jsp页面
<%= request.getParameter("address") %>

```

##  JSP内置对象
所谓内置对象,就是我们可以直接在jsp页面中使用这些对象,不用创建
内置对象如下
>   第一类:作用域对象
>   +   pageContext
>   +   request
>   +   session
>   +   application
> ----------------------------
>   第二类:不常用对象
>   +   exception
>   +   page
>   +   config
> ----------------------------
>   第三类:常用
>   +   response
>   +   out
### 第一类:作用域对象
####    作用域定义
>   表示这个对象可以存值,它们的取值范围有限定

####    作用范围
>   +   pageContext[PageContext]:作用于仅限于当前页面,能够存值的同时,还能获取到其他8个对象
>   +   request[HttpServletRequest]:作用于仅限于一次请求,只要服务器对该请求作出了响应,这个域中的值就没有了
>   +   session[HttpSession]:作用于仅限于一次会话(多次请求与响应)当中
>   +   application[ServletContext]:整个工程都可以访问,服务器关闭后就不能访问了

####    操作
```
//写数据
<% pageContext.setAttribute("name", "zhangsan") %>
<% request.setAttribute("name", "zhangsan") %>
<% session.setAttribute("name", "zhangsan") %>
<% application.setAttribute("name", "zhangsan") %>
//读数据
<%= pageContext.getAttribute("name") %>
<%= request.getAttribute("name") %>
<%= session.getAttribute("name") %>
<%= application.getAttribute("name") %>
```


### 第二类:不常用
>   +   exception => Throwable
>   +   page => Object => 就是jsp翻译成java类的实例对象,就是在类中的this关键字
>   +   config => ServletConfig

### 第三类:常用
>   +   response => HttpServletResponse
>   +   out => JspWriter

####    两者区别
```
<% out.write("这是使用out对象输出的内容") %>
<% response.getWriter().write("这是使用response对象输出的内容") %>

//得到的结果
这是使用response对象输出的内容
这是使用out对象输出的内容

//背后逻辑
1.  碰到out对象输出,会先将out的内容刷新到response的缓冲中
2.  而response.getWriter会直接输出内容
3.  这样,即使out代码写在前面,response代码写在后面,也会先输出response要输出的内容
```

#  EL表达式
>   为了简化jsp代码,具体一点就是为了简化在jsp里面写的那些java代码
>   主要用于取值工作
## 写法格式
```
$( 表达式 )
```
## 具体使用
###    取值方式
如果是有下标的,使用`[]`的方式
```
<%
	String[] a = {"aa", "bb", "cc", "dd"};
	pageContext.setAttribute("arr", a);
%>
<h3>使用EL表达式取出作用域中数组的值</h3>
${arr[0]},${arr[1]},${arr[2]},${arr[3]}
```
如果没有下标,使用`.`的方式
```
<%
	pageContext.getAttribute("name");
%>
<h3>使用EL表达式取出作用域中的值</h3>
${pageScope.name}
```
###    取出4个作用域中存放的值
```html
<body>
<%
	pageContext.setAttribute("name", "page1");
	request.setAttribute("name", "page2");
	session.setAttribute("name", "page3");
	application.setAttribute("name", "page4");
%>
<h3>按普通手段取值</h3>
<%
	pageContext.getAttribute("name");
	request.getAttribute("name");
	session.getAttribute("name");
	application.getAttribute("name");
%>
<h3>使用EL表达式取出作用域中的值</h3>
${pageScope.name}
${requestScope.name}
${sessionScope.name}
${applicationScope.name}

<%
	String[] a = {"aa", "bb", "cc", "dd"};
	pageContext.setAttribute("arr", a);
%>
<h3>使用EL表达式取出作用域中数组的值</h3>
${arr[0]},${arr[1]},${arr[2]},${arr[3]}

<%
	ArrayList list = new ArrayList();
	list.add("11");
	list.add("22");
	list.add("33");
	list.add("44");
	pageContext.setAttribute("li", list);
%>
<h3>使用EL表达式取出作用域中集合的值</h3>
${li[0]},${li[2]},${li[3]},${li[4]}

<%
	HashMap map = new HashMap();
	map.put("name", "zhangsan");
	map.put("page", 18);
	map.put("address", "beijing");
	pageContext.setAttribute("map", map);
%>
<h3>使用EL表达式取出作用域中集合的值</h3>
${map.name},${map.age},${map.address}
</body>
```
###    没有指定作用域,此时取值顺序
```html
<body>
<%
	pageContext.setAttribute("name", "page1");
	request.setAttribute("name", "page2");
	session.setAttribute("name", "page3");
	application.setAttribute("name", "page4");
%>
<h3>有指定作用域,就到对应作用域里找</h3>
${pageScope.name}
${requestScope.name}
${sessionScope.name}
${applicationScope.name

<h3>没有指定作用域</h3>
<h4>先从pageContext里面找,不会在request里找,然后去session里面找,最后去application里面找</h4>
${ name }
</body>
```

### EL表达式的11个内置对象
>   JSP
>   +   pageContext
> -------------------------
>   作用域
>   +   pageScope
>   +   requestScope
>   +   sessionScope
>   +   applicationScope
> -------------------------
>   请求头
>   +   header
>   +   headerValues
> -------------------------
>   请求参数
>   +   param
>   +   paramValues
> ------------------------
>   Cookie
>   +   cookie
> ------------------------
>   初始化参数
>   +   initParam

#  JSTL
## 定义和作用
>   JSP标准标签库,全称:JSP Standard Tag Library
>   简化jsp的代码编写,替换`<% %>`的写法,配合EL使用

### 项目中引入JSTL
1.  复制`jstl.jar`和`standard.jar`文件到工程的WebContent/WEB-INF/lib目录下
2.  在jsp页面上,使用taglib指令来引入标签库
3.  注意:如果想支持EL表达式,那么引入的标签库必须选择1.1的版本,1.0的版本不支持EL表达式
```html
<!-- 在头中引入 -->
<!-- 其中,prefix="c"中的c可以任意值,但是有一定的习惯 -->
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
```

## 常用标签
###    常用的标签
>   +   <c:set></c:set>>
>   +   <c:if></c:if>
>   +   <c:forEach></c:forEach>>
###    举例
```html
<body>
<h1>--------------------赋值操作-----------------------------</h1>
<!-- 声明一个对象name,对象的值为zhangsan,存储到session 如果没有执行scop则默认是page作用域 -->
<c:set var="name" value="zhangsan" scope="session"></c:set>
${sessionScope.name }

<h1>--------------------条件语句-----------------------------</h1>
<c:if test=""></c:if>
<c:set var="age" value="18" scope="session"></c:set>
<!-- test用以写判断条件,var用以存判断结果,scope用以设定作用域 -->
<!-- 没有else -->
<c:if test="${ age >= 6 }" var="flag" scope="page">
	年龄大于5岁
</c:if>

<h1>--------------------循环语句-----------------------------</h1>
<!-- 从1开始遍历到10,步长为2,得到的结果复制给i,并且会存储到page域中 -->
<c:forEach begin="1" end="10" var="i" setp="2">
	${i }
</c:forEach>

<h1>--------------------循环语句,遍历list--------------------</h1>
<!-- items:表示遍历哪一个对象,注意这里必须写EL表达式 -->
<!-- var:遍历出来的每一个元素用user去接受 -->
<%
	ArrayList list = new ArrayList();
	list.add(new User("zhangsan", 18));
	list.add(new User("lisi", 28));
	list.add(new User("wangwu", 38));
	list.add(new User("maliu", 48));
	list.add(new User("qianqi", 58));
%>
<!-- items:表示遍历哪一个对象,注意这里必须写EL表达式 -->
<!-- var:遍历出来的每一个元素用user去接受 -->
<c:forEach var="user" items="${list }">
	${user.name } ---- ${user.age }
</c:forEach>
</body>
```
