#	使用maven编译scala项目时栈溢出

----

原因有很多，需要具体分析代码。在代码是合理的情况下，最简单的办法是修改编译插件的配置。
对编译插件增加配置，如下：

```xml
<!-- 该插件用于将Scala代码编译成class文件 -->
<plugin>
    <groupId>net.alchim31.maven</groupId>
    <artifactId>scala-maven-plugin</artifactId>
    <version>3.4.6</version>
    <executions>
        <execution>
            <!-- 声明绑定到maven的compile阶段 -->
            <goals>
                <goal>testCompile</goal>
            </goals>
            <configuration>
                <jvmArgs>
                    <!-- 需要的配置 -->
                    <jvmArg>-Xss4m</jvmArg>
                </jvmArgs>
            </configuration>
        </execution>
    </executions>
</plugin>
```

#   参考
+   [使用maven编译scala项目时栈溢出](https://blog.csdn.net/weixin_34267123/article/details/92961434)