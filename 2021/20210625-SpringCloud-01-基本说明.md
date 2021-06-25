#   SpringCloud-01-基本说明

---

##  01_前言闲聊和课程说明

[教学视频](https://www.bilibili.com/video/BV18E411x7eT)

##  02_零基础微服务架构理论入门

### 什么是微服务

>   In short, the microservice architectural style is an approach to developing a single application as a suite of small services, each running in its own process and communicating with lightweight mechanisms, often an HTTP resource API. These services are built around business capabilities and independently deployable by fully automated deployment machinery. There is a bare minimum of centralized management of these services, which may be written in different programming languages and use different data storage technologies.——James Lewis and Martin Fowler (2014)

+   微服务是一种架构风格
+   一个应用拆分为一组小型服务
+   每个服务运行在自己的进程内，也就是可独立部署和升级
+   服务之间使用轻量级HTTP交互
+   服务围绕业务功能拆分
+   可以由全自动部署机制独立部署
+   去中心化，服务自治。服务可以使用不同的语言、不同的存储技术

**主题词01：现代数字化生活-落地维度**

+   手机
+   PC
+   智能家居
+   …

**主题词02：分布式微服务架构-落地维度**

满足哪些维度？支撑起这些维度的具体技术？

![](../images/2021/06/20210625113202.png)

+   服务调用
+   服务降级
+   服务注册与发先
+   服务熔断
+   负载均衡
+   服务消息队列
+   服务网关
+   配置中心管理
+   自动化构建部署
+   服务监控
+   全链路追踪
+   服务定时任务
+   调度操作

### Spring Cloud简介

是什么？符合微服务技术维度

**SpringCloud=分布式微服务架构的站式解决方案，是多种微服务架构落地技术的集合体，俗称微服务全家桶**

猜猜SpringCloud这个大集合里有多少种技术?

![](../images/2021/06/20210625113346.png)

SpringCloud俨然已成为微服务开发的主流技术栈，在国内开发者社区非常火爆。

“微”力十足，互联网大厂微服务架构案例

京东的：

![](../images/2021/06/20210625113405.png)

阿里的：

![](../images/2021/06/20210625113421.png)

京东物流的：

![](../images/2021/06/20210625113439.png)

![](../images/2021/06/20210625113450.png)

Spring Cloud技术栈

![](../images/2021/06/20210625113502.png)

![](../images/2021/06/20210625113508.png)

![](../images/2021/06/20210625113513.png)

### 总结

![](../images/2021/06/20210625113522.png)

##  03_Boot和Cloud版本选型

+   Spring Boot 2.X 版
    -   [源码地址](https://github.com/spring-projects/spring-boot/releases/)
    -   [Spring Boot 2 的新特性](https://github.com/spring-projects/spring-boot/wiki/spring-Boot-2.0-Release-Notes)
    -   通过上面官网发现，Boot官方强烈建议你升级到2.X以上版本

+   Spring Cloud H版
    -   [源码地址](https://github.com/spring-projects/spring-cloud)
    -   [官网](https://spring.io/projects/spring-cloud)

+   Spring Boot 与 Spring Cloud 兼容性查看
    -   [文档](https://spring.io/projects/spring-cloud#adding-spring-cloud-to-an-existing-spring-boot-application)
    -   [JSON接口](https://start.spring.io/actuator/info)

+   接下来开发用到的组件版本
    -   Cloud - Hoxton.SR1
    -   Boot - 2.2.2.RELEASE
    -   Cloud Alibaba - 2.1.0.RELEASE
    -   Java - Java 8
    -   Maven - 3.5及以上
    -   MySQL - 5.7及以上

##  04_Cloud组件停更说明

+   停更引发的“升级惨案”
    -   停更不停用
    -   被动修复bugs
    -   不再接受合并请求
    -   不再发布新版本

+   Cloud升级

+   服务注册中心
    -   × Eureka
    -   √ Zookeeper
    -   √ Consul
    -   √ Nacos

+   服务调用
    -   √ Ribbon
    -   √ LoadBalancer

+   服务调用2
    -   × Feign
    -   √ OpenFeign

+   服务降级
    -   × Hystrix
    -   √ resilience4j
    -   √ sentienl

+   服务网关
    -   × Zuul
    -   ! Zuul2
    -   √ gateway

+   服务配置
    -   × Config
    -   √ Nacos

+   服务总线
    -   × Bus
    -   √ Nacos

+   [Spring Cloud官方文档](https://cloud.spring.io/spring-cloud-static/Hoxton.SR1/reference/htmlsingle/)

+   [Spring Cloud中文文档](https://www.bookstack.cn/read/spring-cloud-docs/docs-index.md)

+   [Spring Boot官方文档](https://docs.spring.io/spring-boot/docs/2.2.2.RELEASE/reference/htmlsingle/)
