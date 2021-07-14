#   Spring Security OAuth2.0认证授权一：框架搭建和认证测试

---

#   OAuth2.0介绍

OAuth（开放授权）是一个开放标准，允许用户授权第三方应用访问他们存储在另外的服务提供者上的信息，而不 需要将用户名和密码提供给第三方应用或分享他们数据的所有内容。

##  stackoverflow和github

听起来挺拗口，不如举个例子说明下，就以stackoverflow登录为例：我们登录stackoverflow，网站上会提示几种登录方式，如下所示

20210714155958.png

其中有一种github登录的方式，点一下进入以下页面

20210714160008.png

这个页面实际上是github授权登陆stackoverflow的页面，只要点击授权按钮，就可以使用github上注册的相关信息注册stackoverflow了，仔细看下这个授权页面，这个授权页面上有几个值得注意的点：

1.  图片中介绍了三方角色信息：当前操作人，github以及stackoverflow

2.  stackoverflow想通过github获取你的个人信息，哪些个人信息呢？Email addresses (read-only),邮箱地址，而且是只读，也就是说就算你授权了stackoverflow，它也修改不了你github上的个人信息。

3.  授权按钮，以及下面的一行小字Authorizing will redirect to `**https://stackauth.com**`，也就是说如果你点击了授权按钮，页面将重定向到stackauth.com页面。点击授权按钮之后就仿佛使用github的账号登录上了stackoverflow一样。

这里操作人、github、stackoverflow分别扮演了什么角色，stackoverflow是如何从github获取到个人信息的呢？这里实际上使用的是auth2.0协议进行的认证和授权。

##  auth2.0协议

我们看OAuth2.0认证流程：引自OAauth2.0协议rfc6749 https://tools.ietf.org/html/rfc6749

```
 +--------+                               +---------------+
     |        |--(A)- Authorization Request ->|   Resource    |
     |        |                               |     Owner     |
     |        |<-(B)-- Authorization Grant ---|               |
     |        |                               +---------------+
     |        |
     |        |                               +---------------+
     |        |--(C)-- Authorization Grant -->| Authorization |
     | Client |                               |     Server    |
     |        |<-(D)----- Access Token -------|               |
     |        |                               +---------------+
     |        |
     |        |                               +---------------+
     |        |--(E)----- Access Token ------>|    Resource   |
     |        |                               |     Server    |
     |        |<-(F)--- Protected Resource ---|               |
     +--------+                               +---------------+

                     Figure 1: Abstract Protocol Flow

   The abstract OAuth 2.0 flow illustrated in Figure 1 describes the
   interaction between the four roles and includes the following steps:

   (A)  The client requests authorization from the resource owner.  The
        authorization request can be made directly to the resource owner
        (as shown), or preferably indirectly via the authorization
        server as an intermediary.

   (B)  The client receives an authorization grant, which is a
        credential representing the resource owner's authorization,
        expressed using one of four grant types defined in this
        specification or using an extension grant type.  The
        authorization grant type depends on the method used by the
        client to request authorization and the types supported by the
        authorization server.

   (C)  The client requests an access token by authenticating with the
        authorization server and presenting the authorization grant.

   (D)  The authorization server authenticates the client and validates
        the authorization grant, and if valid, issues an access token.

   (E)  The client requests the protected resource from the resource
        server and authenticates by presenting the access token.

   (F)  The resource server validates the access token, and if valid,
        serves the request.

Hardt                        Standards Track                    [Page 7]
```

OAauth2.0包括以下角色：

1.  客户端

本身不存储资源，需要通过资源拥有者的授权去请求资源服务器的资源，比如：Android客户端、Web客户端（浏
览器端）、微信客户端等，在上面的例子中，stackoverflow扮演的正是这个角色。

2.  资源拥有者

通常为用户，也可以是应用程序，即该资源的拥有者。在上面的例子中，资源拥有者指的是在github上已经注册的用户。

3.  授权服务器（也称认证服务器）

用于服务提供商对资源拥有的身份进行认证、对访问资源进行授权，认证成功后会给客户端发放令牌
（access_token），作为客户端访问资源服务器的凭据。本例为github。

4.  资源服务器

存储资源的服务器，本例子为github存储的用户信息。

如此，上面使用github登陆stackoverflow的流程大体上如下图所示：

20210714160143.png

下面将演示如何使用spring boot搭建OAuth2.0认证中心以实现类似于stackoverflow使用github账号登陆的效果。

#   使用springboot搭建OAuth2.0认证中心

项目目录层次如下：

```
├── docs
│   └── sql
│       └── init.sql
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── kdyzm
    │   │           └── spring
    │   │               └── security
    │   │                   └── auth
    │   │                       └── center
    │   │                           ├── AuthCenterApplication.java
    │   │                           ├── config
    │   │                           │   ├── AuthorizationServer.java
    │   │                           │   ├── MybatisPlusConfig.java
    │   │                           │   ├── TokenConfig.java
    │   │                           │   └── WebSecurityConfig.java
    │   │                           ├── controller
    │   │                           │   └── GrantController.java
    │   │                           ├── entity
    │   │                           │   └── TUser.java
    │   │                           ├── handler
    │   │                           │   └── MyAuthenticationFailureHandler.java
    │   │                           ├── mapper
    │   │                           │   └── UserMapper.java
    │   │                           └── service
    │   │                               └── MyUserDetailsServiceImpl.java
    │   └── resources
    │       ├── application.yml
    │       ├── static
    │       │   ├── css
    │       │   │   ├── bootstrap.min.css
    │       │   │   └── signin.css
    │       │   └── login.html
    │       └── templates
    │           └── grant.html
```

接下来捡着重点说下搭建过程

##  引入最核心的三个maven依赖
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-oauth2</artifactId>
</dependency>
```

像是mybatis、mybatis plus、fastjson、lombok、thymeleaf等依赖都是辅助依赖，不赘述

##  编写启动类
```java
@SpringBootApplication
public class AuthCenterApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthCenterApplication.class, args);
    }
}
```

##  配置文件
```yaml
server:
  port: 30000
spring:
  application:
    name: auth-center
  datasource:
    url: jdbc:mysql://${db}/security?useSSL=false&userUnicode=true&characterEncoding=utf-8&serverTimezone=UTC
    username: root
    password: ${db_password}
    driver-class-name: com.mysql.jdbc.Driver
  thymeleaf:
    prefix: classpath:/templates/
    suffix: .html
    cache: false
```

配置完以上三项，就可以将项目正常启动起来了，但是是一个一片空白的项目。接下来配置核心代码实现

##  EnableAuthorizationServer

可以用 @EnableAuthorizationServer 注解并继承AuthorizationServerConfigurerAdapter来配置OAuth2.0 授权服务器。

在config包下创建AuthorizationServer：

```java
@Configuration
@EnableAuthorizationServer
public class AuthorizationServer extends AuthorizationServerConfigurerAdapter{
    ......
}
```

AuthorizationServerConfigurerAdapter要求重写以下三个方法并配置方法中的几个类，这几个类是由Spring创建的独立的配置对象，它们会被Spring传入AuthorizationServerConfigurer中进行配置。

```java
public void configure(AuthorizationServerSecurityConfigurer security) throws Exception {}
public void configure(ClientDetailsServiceConfigurer clients) throws Exception {}
public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {}
```

+   ClientDetailsServiceConfigurer ：用来配置客户端详情服务（ClientDetailsService），客户端详情信息在这里进行初始化，你能够把客户端详情信息写死在这里或者是通过数据库来存储调取详情信息。
+   AuthorizationServerEndpointsConfigurer ：用来配置令牌（token）的访问端点和令牌服务(tokenservices)。
+   AuthorizationServerSecurityConfigurer ：用来配置令牌端点的安全约束.

##  配置客户端详细信息

ClientDetailsServiceConfigurer 能够使用内存或者JDBC来实现客户端详情服务（ClientDetailsService），ClientDetailsService负责查找ClientDetails，而ClientDetails有几个重要的属性如下列表：

+   clientId ：（必须的）用来标识客户的Id。
+   secret ：（需要值得信任的客户端）客户端安全码，如果有的话。
+   scope ：用来限制客户端的访问范围，如果为空（默认）的话，那么客户端拥有全部的访问范围。
+   authorizedGrantTypes ：此客户端可以使用的授权类型，默认为空。
+   authorities ：此客户端可以使用的权限（基于Spring Security authorities）。

客户端详情（Client Details）能够在应用程序运行的时候进行更新，可以通过访问底层的存储服务（例如将客户端详情存储在一个关系数据库的表中，就可以使用 JdbcClientDetailsService）或者通过自己实现ClientRegistrationService接口（同时你也可以实现 ClientDetailsService 接口）来进行管理。

我们暂时使用内存方式存储客户端详情信息，配置如下:

```java
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.inMemory()              //使用in‐memory存储
                .withClient("c1")
                .secret(new BCryptPasswordEncoder().encode("secret"))//$2a$10$0uhIO.ADUFv7OQ/kuwsC1.o3JYvnevt5y3qX/ji0AUXs4KYGio3q6
                .resourceIds("r1")
                .authorizedGrantTypes("authorization_code", "password", "client_credentials", "implicit", "refresh_token")//该client允许的授权类型
                .scopes("all")          //授权范围
                .autoApprove(false)
                .redirectUris("https://www.baidu.com");
    }
```

##  管理令牌

AuthorizationServerTokenServices 接口定义了一些操作使得你可以对令牌进行一些必要的管理，令牌可以被用来加载身份信息，里面包含了这个令牌的相关权限。

自己可以创建 AuthorizationServerTokenServices 这个接口的实现，则需要继承 DefaultTokenServices 这个类，里面包含了一些有用实现，你可以使用它来修改令牌的格式和令牌的存储。默认的，当它尝试创建一个令牌的时候，是使用随机值来进行填充的，除了持久化令牌是委托一个 TokenStore 接口来实现以外，这个类几乎帮你做了所有的事情。并且 TokenStore 这个接口有一个默认的实现，它就是 InMemoryTokenStore ，如其命名，所有的令牌是被保存在了内存中。除了使用这个类以外，你还可以使用一些其他的预定义实现，下面有几个版本，它们都实现了TokenStore接口：

+   InMemoryTokenStore ：这个版本的实现是被默认采用的，它可以完美的工作在单服务器上（即访问并发量压力不大的情况下，并且它在失败的时候不会进行备份），大多数的项目都可以使用这个版本的实现来进行尝试，你可以在开发的时候使用它来进行管理，因为不会被保存到磁盘中，所以更易于调试。
+   JdbcTokenStore ：这是一个基于JDBC的实现版本，令牌会被保存进关系型数据库。使用这个版本的实现时，你可以在不同的服务器之间共享令牌信息，使用这个版本的时候请注意把"spring-jdbc"这个依赖加入到你的classpath当中。
+   JwtTokenStore ：这个版本的全称是 JSON Web Token（JWT），它可以把令牌相关的数据进行编码（因此对于后端服务来说，它不需要进行存储，这将是一个重大优势），但是它有一个缺点，那就是撤销一个已经授权令牌将会非常困难，所以它通常用来处理一个生命周期较短的令牌以及撤销刷新令牌（refresh_token）。另外一个缺点就是这个令牌占用的空间会比较大，如果你加入了比较多用户凭证信息。JwtTokenStore 不会保存任何数据，但是它在转换令牌值以及授权信息方面与 DefaultTokenServices 所扮演的角色是一样的。

### 定义TokenConfig

在config包下定义TokenConfig，我们暂时先使用InMemoryTokenStore，生成一个普通的令牌。

### 定义ClientDetailsService

由于配置了5，所以这里会spring会帮我们生成一个基于内存的 ClientDetailsService

### 定义AuthorizationServerTokenServices

在AuthorizationServer中定义AuthorizationServerTokenServices
