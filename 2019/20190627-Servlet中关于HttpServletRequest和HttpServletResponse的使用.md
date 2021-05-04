#   Servlet中关于HttpServletRequest和HttpServletResponse的使用
date: 2019-06-27 23:15:01
description: HttpServletRequest和HttpServletResponse的使用
tags:
- Servlet
categories:
- Java
---
##  HttpServletRequest
### 作用
这个对象封装了客户端提交过来的一切数据,包括
1.  取得头信息
2.  取得客户端提交上来的数据

### 使用
1.  取得头信息
```java
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// 取出请求里面的头信息
		Enumeration<String> headerNames = req.getHeaderNames();
		while (headerNames.hasMoreElements()) {
			String name = (String) headerNames.nextElement();
			String value = req.getHeader(name);
			System.out.println(name + "=" + value);
		}
	}
```

2.  取得客户端提交上来的数据
```java
protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		//1. 获取客户端提交上来的数据
		String name = req.getParameter("name");
		System.out.println("name=" + name);
		String address = req.getParameter("address");
		System.out.println("address=" + address);

		//2. 获取所有参数,得到枚举集合
		//Enumeration<String> parameterNames = req.getParameterNames();

		//3. 获取所有参数,得到一个Map集合
		//这里Map<String, String[]>中,后一个是String[],表明是一个数组
		//产生的原因是因为我们访问的时候是有如下可能的,只是我们一般不会这样写
		//name=1&name=2&name=3
		Map<String, String[]> map = req.getParameterMap();
		Set<String> keySet = map.keySet();
		//创建一个迭代器
		Iterator<String> iterator = keySet.iterator();
		while (iterator.hasNext()) {
			String key = (String) iterator.next();
			String value = map.get(key)[0];
			System.out.println(key + "=" + value);
		}
	}
```
### 需要解决的问题
####    处理中文乱码
1.  方法一,在代码中进行转码
```java
	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {
		String username = req.getParameter("username");
		String password = req.getParameter("password");

		//get请求过来的数据,在url地址栏上就已经经过编码了,所以我们取到的就是乱码
		//tomcat收到这批数据,getParameter默认使用ISO-8859-1去解码
		//先让文字回到ISO-8859-1对应的字节数组,然后在按UTF-8组拼字符串
		//getBytes(String charsetName): 使用指定的字符集将字符串编码为 byte 序列，并将结果存储到一个新的 byte 数组中。
		username = new String(username.getBytes("ISO-8859-1"), "UTF-8");
		password = new String(password.getBytes("ISO-8859-1"), "UTF-8");
	}
```

2.  方法二,直接在tomcat中修改
打开server.xml文件,在如下指定位置加上`URIEncoding="UTF-8"`
```xml
<Connector connectionTimeout="20000" port="8080" protocol="HTTP/1.1" redirectPort="8443" URIEncoding="UTF-8"/>
```

3.  方法二：对请求头进行编码转换
该方法只对POST方式提交的数据有效，对GET方式提交的数据无效!
```java
request.setCharacterEncoding("UTF-8");
```

##  HttpServletResponse
### 作用
>   负责返回数据给客户端

### 使用
####    输出数据
```java
	private void test01(HttpServletResponse resp) throws IOException {
		// 以字符流的方式写数据
		resp.getWriter().write("<h1>hello response...</h1>");
		// 以字节流的方式写数据
		resp.getOutputStream().write("hello".getBytes());;

		// 设置当前这个请求的处理状态码
		//resp.setStatus("");
		// 设置一个头
		//resp.setHeader(name, value);
		// 设置响应的内容类型,以及编码
		//resp.setContentType(type);
	}
```

####    下载文件
```java
	private void test04(HttpServletRequest req, HttpServletResponse resp)
			throws FileNotFoundException, IOException {
		// 1.获取要下载文件名称
		String fileName = req.getParameter("filename");
		// 1.5 名字中带有中文
        // 下载框中文件名是乱码或不显示的时候，往往是由于我们没有对中文文件名进行编码处理
        // 针对浏览器类型，对文件名字做编码处理 Firefox (Base64) , IE、Chrome（UTF-8）
		String clientType = req.getHeader("User-Agent");
		if (clientType.contains("Firefox")) {
			fileName = DownLoadUtil.base64EncodeFileName(fileName);
		} else {
			fileName = URLEncoder.encode(fileName, "UTF-8");
		}
		// 2.获取这个文件在tomcat里面的绝对路径地址
		String path = getServletContext().getRealPath("download/" + fileName);
		// 3.转化成输入流
		FileInputStream is = new FileInputStream(path);

		// 准备输出
		// 4.准备输出流
		ServletOutputStream os = resp.getOutputStream();
		// 5.准备浏览器头,用以弹出下载框
		resp.setHeader("Content-Disposition", "attachment; filename=" + fileName);
		// 6.将输入流写到输出流
		int len = 0;
		byte[] buffer = new byte[1024];
		while ((len = is.read(buffer)) != -1) {
			os.write(buffer, 0, len);
		}
		os.close();
		is.close();
	}
```

```java
// 上述代码使用的工具类
import java.io.UnsupportedEncodingException;

import sun.misc.BASE64Encoder;

public class DownLoadUtil {
	public static String base64EncodeFileName(String fileName) {
		BASE64Encoder base64Encoder = new BASE64Encoder();
		try {
			return "=?UTF-8?B?"
					+ new String(base64Encoder.encode(fileName.getBytes("UTF-8")))
					+ "?=";
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		}
	}
}
```
如果是中文文件下载,需要针对浏览器,对文件名字做编码处理 Firefox (Base64), IE和chrome使用URLEncoder

### 会出现的问题
####    处理响应中文乱码问题
1.  以字符流输出 -> resp.getWriter()
```java
private void test02(HttpServletResponse resp) throws IOException {
    //响应的中文乱码问题

    //1. 指定输出到客户端的时候,这些文字使用UTF-8编码
    //这里写出去的文字,默认使用的是ISO-8859-1,我们可以指定写出去的时候,使用什么编码写
    resp.setCharacterEncoding("UTF-8");

    //2. 直接规定浏览器看这份数据的时候,使用什么编码来看
    resp.setHeader("Content-Type", "text/html; charset=UTF-8");
    resp.getWriter().write("中文输出");
}

// resp.setCharacterEncoding("UTF-8")和resp.setHeader("Content-Type", "text/html; charset=UTF-8")可以合并成一句话
// 即,可以用一句话来设置响应的数据类型
private void test02(HttpServletResponse resp) throws IOException {
    resp.setContentType("text/html;charset=UTF-8");
    resp.getWriter().write("中文输出");
}
```

2.  以字节流输出 -> getOutputStream()
```java
private void test03(HttpServletResponse resp)
        throws IOException, UnsupportedEncodingException {
    // 如果想让服务端出去的中文,在客户端能够正常显示,只要确保
    // 出去的时候使用的编码和浏览器看这份数据使用的编码是一样的
    // 1. 指定浏览器看这份数据使用的编码
    resp.setHeader("Content-Type", "text/html; charset=UTF-8");
    // 2. 指定输出中文时使用的编码
    // 默认情况下getOutputStream输出使用的是UTF-8码表
    // 但为了确保万无一失,指定一下编码比较好
    resp.getOutputStream().write("中文测试".getBytes("UTF-8"));

// 可以使用一句话来设置响应的数据类型
private void test03(HttpServletResponse resp)
        throws IOException, UnsupportedEncodingException {
    resp.setContentType("text/html;charset=UTF-8");
    resp.getOutputStream().write("中文测试".getBytes("UTF-8"));
}
```

##  请求转发和重定向
### 重定向
####    什么是重定向
1.  地址上显示的是最后的哪个资源的路径地址
2.  请求次数最少有两次,服务器在第一次请求后,会返回302以及一个地址,浏览器再根据这个地址,执行第二次访问
3.  可以跳转到任意路径,不是自己的工程也可以跳
4.  效率稍微低一点,指向两次请求
5.  后续的请求,没法使用上一次request对象,因为这是两次不同的请求

####    代码
```java
	private void test02(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		//1.获取数据
		String userName = req.getParameter("username");
		String password = req.getParameter("password");
		//2.校验数据,并返回给客户端
		PrintWriter pw = resp.getWriter();
		if ("admin".equals(userName) && "123".equals(password) ) {
//			//之前的写法
//			//4.设置状态码
//			resp.setStatus(302);
//			//5.定位跳转的位置是哪一个页面
//			resp.setHeader("Location", "login_success.html");

			//重定向写法
			resp.sendRedirect("login_success.html");
		} else {
			//失败,打印失败数据到网页
			pw.write("login failed...");
		}
	}
```

### 请求转发
####    什么是请求转发
1.  地址栏上显示的是请求servlet的地址
2.  请求次数只有一次,因为是服务器内部帮助客户端执行了后续的工作
3.  只能跳转自己项目的资源路径
4.  效率上稍微高一点,因为只执行一次请求
5.  后续的请求,可以使用上一次request对象,因为只有一次请求

####    代码
```java
	private void test03(HttpServletRequest req, HttpServletResponse resp)
			throws IOException, ServletException {
		//1.获取数据
		String userName = req.getParameter("username");
		String password = req.getParameter("password");
		//2.校验数据,并返回给客户端
		PrintWriter pw = resp.getWriter();
		if ("admin".equals(userName) && "123".equals(password) ) {
			req.getRequestDispatcher("login_success.html").forward(req, resp);
		} else {
			//失败,打印失败数据到网页
			pw.write("login failed...");
		}
	}
```
