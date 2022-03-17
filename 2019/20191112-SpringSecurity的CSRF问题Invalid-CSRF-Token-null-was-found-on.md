# SpringSecurity的CSRF问题Invalid CSRF Token null was found on...
+ date: 2019-11-12 09:48:48
+ description: SpringSecurity的CSRF问题Invalid CSRF Token null was found on...
+ categories:
  - Java
+ tags:
  - Java细节
- Spring
- SpringSecurity
---
# 参考与引用
[Spring Security笔记：解决CsrfFilter与Rest服务Post方式的矛盾](https://www.cnblogs.com/yjmyzz/p/customize-CsrfFilter-to-ignore-certain-post-http-request.html)
[security禁用csrf](https://blog.csdn.net/icanactnow2/article/details/53515844)
[spring security CSRF 问题 Invalid CSRF Token 'null' was found on ......](https://blog.csdn.net/u012373815/article/details/55047285)

# 问题
pring security在集成spring boot的微服务框架后，实现了cas认证和权限控制。只要使用post进行请求都会有如下问题
```
HTTP Status 403－Invalid CSRF Token 'null' was found on the request parameter '_csrf' or header 'X-CSRF-TOKEN'.
```
## 原因
Spring Security 4.0之后，引入了CSRF，默认是开启。

## 重点
不得不说，CSRF和RESTful技术有冲突。CSRF默认支持的方法：
+   GET
+   HEAD
+   TRACE
+   OPTIONS
+   **不支持POST**

源码如下,POST方法被排除在外了,也就是说只有GET|HEAD|TRACE|OPTIONS这4类方法会被放行，其它Method的http请求，都要验证\_csrf的token是否正确，而通常post方式调用rest服务时，又没有\_csrf的token，所以校验失败。
```java
private static final class DefaultRequiresCsrfMatcher implements RequestMatcher {
    private Pattern allowedMethods = Pattern.compile("^(GET|HEAD|TRACE|OPTIONS)$");

    /* (non-Javadoc)
     * @see org.springframework.security.web.util.matcher.RequestMatcher#matches(javax.servlet.http.HttpServletRequest)
     */
    public boolean matches(HttpServletRequest request) {
        return !allowedMethods.matcher(request.getMethod()).matches();
    }
}
```

## 什么是csrf
科普一下，什么是csrf,这是一个web应用安全的问题，CSRF（Cross-site request forgery跨站请求伪造，也被称为“One Click Attack” 或者Session Riding，攻击方通过伪造用户请求访问受信任站点。

我们知道，客户端与服务端在基于http协议在交互的数据的时候，由于http协议本身是无状态协议，后来引进了cookie的 方式进行记录服务端和客户端的之间交互的状态和标记。cookie里面一般会放置服务端生成的session id（会话ID）用来识别客户端访问服务端过 程中的客户端的身份标记。

在跨域 (科普一下：同一个ip、同一个网络协议、同一个端口，三者都满足就是同一个域，否则就有跨域问题) 的情况下， session id可能会被恶意第三方劫持，此时劫持这个session id的第三方会根据这个session id向服务器发起请求，此时服务器收到这个请求会认为这是合法的请求，并返回根据请求完成相应的服务端更新。

## 为什么允许get而不允许post
如果这个http请求是get方式发起的请求，意味着它只是访问服务器 的资源，仅仅只是查询，没有更新服务器的资源，所以对于这类请求，spring security的防御策略是允许的，

如果这个请求是通过post请求发起的， 那么spring security是默认拦截这类请求的，因为这类请求是带有更新服务器资源的危险操作，如果恶意第三方可以通过劫持session id来更新 服务器资源，那会造成服务器数据被非法的篡改，所以这类请求是会被Spring security拦截的，在默认的情况下，spring security是启用csrf 拦截功能的，这会造成，在跨域的情况下，post方式提交的请求都会被拦截无法被处理（包括合理的post请求），前端发起的post请求后端无法正常 处理，虽然保证了跨域的安全性，但影响了正常的使用，如果关闭csrf防护功能，虽然可以正常处理post请求，但是无法防范通过劫持session id的非法的post请求

# 解决
原因找到了：spring Security 3默认关闭csrf，Spring Security 4默认启动了csrf

## 如果不采用csrf，可禁用security的csrf
Java注解方式配置：

加上 .csrf().disable()即可。

修改前WebSecurityConfig.java
```java
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .antMatchers("/", "/home").permitAll()
                .and()
                .formLogin()
                .loginPage("/login").permitAll()
                .and()
                .logout().logoutUrl("/logout")
                .logoutSuccessUrl("/hello")
                .permitAll();
        http.addFilterBefore(customizeFilterSecurityInterceptor, FilterSecurityInterceptor.class)
                .csrf().disable();
    }
```

##  不关闭csrf防护功能的前提下spring security要如何才能使用post
### 方案一
自己弄一个Matcher,既然源码中不允许POST,我们就自定义一个,放行就好
```java
package com.cnblogs.yjmyzz.utils;

import java.util.List;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;

import org.springframework.security.web.util.matcher.RequestMatcher;

public class CsrfSecurityRequestMatcher implements RequestMatcher {
    private Pattern allowedMethods = Pattern
            .compile("^(GET|HEAD|TRACE|OPTIONS)$");

    public boolean matches(HttpServletRequest request) {

        if (execludeUrls != null && execludeUrls.size() > 0) {
            String servletPath = request.getServletPath();
            for (String url : execludeUrls) {
                if (servletPath.contains(url)) {
                    return false;
                }
            }
        }
        return !allowedMethods.matcher(request.getMethod()).matches();
    }

    /**
     * 需要排除的url列表
     */
    private List<String> execludeUrls;

    public List<String> getExecludeUrls() {
        return execludeUrls;
    }

    public void setExecludeUrls(List<String> execludeUrls) {
        this.execludeUrls = execludeUrls;
    }
}
```
这里添加了一个属性execludeUrls，允许人为排除哪些url。

然后在配置文件里，这样修改：
```xml
 <http entry-point-ref="loginEntryPoint" use-expressions="true">
      ...
      <intercept-url pattern="/rest/**" access="permitAll" />
      ...
      <csrf request-matcher-ref="csrfSecurityRequestMatcher"/>        
  </http>
  
  <beans:bean id="csrfSecurityRequestMatcher" class="com.cnblogs.yjmyzz.utils.CsrfSecurityRequestMatcher">
      <beans:property name="execludeUrls">
          <beans:list>
              <beans:value>/rest/</beans:value>
          </beans:list>
      </beans:property>
  </beans:bean>
```

### 方案二
spring security为了正确的区别合法的post请求，采用了token的机制。

在跨域的场景下，客户端访问服务端会首先发起get请求，这个get请求在到达服务端的时候，服务端的Spring security会有一个过滤 器 CsrfFilter去检查这个请求，如果这个request请求的http header里面的X-CSRF-COOKIE的token值为空的时候，服务端就好自动生成一个 token值放进这个X-CSRF-COOKIE值里面，客户端在get请求的header里面获取到这个值，如果客户端有表单提交的post请求，则要求客户端要 携带这个token值给服务端，在post请求的header里面设置\_csrf属性的token值，提交的方式可以是ajax也可以是放在form里面设置hidden 属性的标签里面提交给服务端，服务端就会根据post请求里面携带的token值进行校验，如果跟服务端发送给合法客户端的token值是一样的，那么 这个post请求就可以受理和处理，如果不一样或者为空，就会被拦截。由于恶意第三方可以劫持session id，而很难获取token值，所以起到了安全的防护作用。
