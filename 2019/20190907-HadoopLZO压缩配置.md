#   HadoopLZO压缩配置
+ date: 2019-09-07 11:58:01
+ description: HadoopLZO压缩配置
+ categories:
  - BigData
+ tags:
  - Hadoop
---
1. 先下载lzo的jar项目

[https://github.com/twitter/hadoop-lzo/archive/master.zip](https://github.com/twitter/hadoop-lzo/archive/master.zip)

2. 下载后的文件名是hadoop-lzo-master，它是一个zip格式的压缩包，先进行解压，然后用maven编译。生成hadoop-lzo-0.4.20.jar。


3. 将编译好后的hadoop-lzo-0.4.20.jar 放入hadoop-2.7.2/share/hadoop/common/

```
$ pwd
/opt/module/hadoop-2.7.2/share/hadoop/common

$ ls
hadoop-lzo-0.4.20.jar
```


4. 同步hadoop-lzo-0.4.20.jar到hadoop103、hadoop104

```
$ xsync hadoop-lzo-0.4.20.jar
```


5. core-site.xml增加配置支持LZO压缩

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>

<property>
<name>io.compression.codecs</name>
<value>
org.apache.hadoop.io.compress.GzipCodec,
org.apache.hadoop.io.compress.DefaultCodec,
org.apache.hadoop.io.compress.BZip2Codec,
org.apache.hadoop.io.compress.SnappyCodec,
com.hadoop.compression.lzo.LzoCodec,
com.hadoop.compression.lzo.LzopCodec
</value>
</property>

<property>
    <name>io.compression.codec.lzo.class</name>
    <value>com.hadoop.compression.lzo.LzoCodec</value>
</property>
</configuration>
```


6. 同步core-site.xml到hadoop103、hadoop104

```
$ xsync core-site.xml
```


7. 启动及查看集群

```
$ sbin/start-dfs.sh
$ sbin/start-yarn.sh
```

8.  web和进程查看
+   Web查看：http://hadoop102:50070
+   进程查看：jps查看各个节点状态。

9.  当启动发生错误的时候：
+   查看日志：/home/atguigu/module/hadoop-2.7.2/logs
+   如果进入安全模式，可以通过hdfs dfsadmin -safemode leave
+   停止所有进程，删除data和log文件夹，然后hdfs namenode -format 来格式化
