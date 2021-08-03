#   Clickhouse最佳实战之分布式集群方案研究

----

#   ClickHouse分布式集群方案研究

官方网站：https://clickhouse.tech/docs/en/introduction/distinctive-features/

Hadoop系列的集群是服务级别的，而Clickhouse的集群是表级别的

##  ClickHouse核心的配置文件解析

1.  /etc/clickhouse-server/config.xml 端口配置、本地机器名配置、内存设置等；config.xml 核心配置文件中文解释

```xml
<?xml version="1.0"?>
<yandex>
   <!-- 日志 -->
   <logger>
       <level>trace</level>
       <log>/data1/clickhouse/log/server.log</log>
       <errorlog>/data1/clickhouse/log/error.log</errorlog>
       <size>1000M</size>
       <count>10</count>
   </logger>

   <!-- 端口 -->
   <http_port>8123</http_port>
   <tcp_port>9000</tcp_port>
   <interserver_http_port>9009</interserver_http_port>

   <!-- 本机域名 -->
   <interserver_http_host>这里需要用域名，如果后续用到复制的话</interserver_http_host>

   <!-- 监听IP -->
   <listen_host>0.0.0.0</listen_host>
   <!-- 最大连接数 -->
   <max_connections>64</max_connections>

   <!-- 没搞懂的参数 -->
   <keep_alive_timeout>3</keep_alive_timeout>

   <!-- 最大并发查询数 -->
   <max_concurrent_queries>16</max_concurrent_queries>

   <!-- 单位是B -->
   <uncompressed_cache_size>8589934592</uncompressed_cache_size>
   <mark_cache_size>10737418240</mark_cache_size>

   <!-- 存储路径 -->
   <path>/data1/clickhouse/</path>
   <tmp_path>/data1/clickhouse/tmp/</tmp_path>

   <!-- user配置 -->
   <users_config>users.xml</users_config>
   <default_profile>default</default_profile>

   <log_queries>1</log_queries>

   <default_database>default</default_database>

   <remote_servers incl="clickhouse_remote_servers" />
   <zookeeper incl="zookeeper-servers" optional="true" />
   <macros incl="macros" optional="true" />

   <!-- 没搞懂的参数 -->
   <builtin_dictionaries_reload_interval>3600</builtin_dictionaries_reload_interval>

   <!-- 控制大表的删除 -->
   <max_table_size_to_drop>0</max_table_size_to_drop>

   <include_from>/data1/clickhouse/metrika.xml</include_from>
</yandex>
```

2.  /etc/clickhouse-server/metrika.xml 集群配置、ZK配置、分片配置等；metrika.xml核心配置文件中文注解

```xml
<yandex>
<!-- 集群配置 -->
<clickhouse_remote_servers>
    <!-- 集群名称-->
    <bip_ck_cluster>
        <shard>
            <internal_replication>false</internal_replication>
            <replica>
                <host>ck1.xxxx.com.cn</host>
                <port>9000</port>
                <user>default</user>
                <password>******</password>
            </replica>
            <replica>
                <host>ck2.xxxx.com.cn</host>
                <port>9000</port>
                <user>default</user>
                <password>******</password>
            </replica>
        </shard>
        <shard>
            <internal_replication>false</internal_replication>
            <replica>
                <host>ck2.xxxx.com.cn</host>
                <port>9000</port>
                <user>default</user>
                <password>******</password>
            </replica>
            <replica>
                <host>ck3.xxxxa.com.cn</host>
                <port>9000</port>
                <user>default</user>
                <password>******</password>
            </replica>
        </shard>
        <shard>
            <internal_replication>false</internal_replication>
            <replica>
                <host>ck3.xxxxa.com.cn</host>
                <port>9000</port>
                <user>default</user>
                <password>******</password>
            </replica>
            <replica>
                <host>ck1.xxxx.com.cn</host>
                <port>9000</port>
                <user>default</user>
                <password>******</password>
            </replica>
        </shard>
    </bip_ck_cluster>
</clickhouse_remote_servers>

<!-- 本节点副本名称（这里无用） -->
<macros>
    <replica>ck1</replica>
</macros>

<!-- 监听网络（貌似重复） -->
<networks>
   <ip>::/0</ip>
</networks>
<!-- ZK  -->
<zookeeper-servers>
  <node index="1">
    <host>1.xxxx.sina.com.cn</host>
    <port>2181</port>
  </node>
  <node index="2">
    <host>2.xxxx.sina.com.cn</host>
    <port>2181</port>
  </node>
  <node index="3">
    <host>3.xxxxp.sina.com.cn</host>
    <port>2181</port>
  </node>
</zookeeper-servers>
<!-- 数据压缩算法  -->
<clickhouse_compression>
<case>
  <min_part_size>10000000000</min_part_size>
  <min_part_size_ratio>0.01</min_part_size_ratio>
  <method>lz4</method>
</case>
</clickhouse_compression>

</yandex>
```

3.  /etc/clickhouse-server/users.xml 权限、配额设置；user.xml核心配置文件中文注解

```xml
<?xml version="1.0"?>
<yandex>
    <profiles>
        <!-- 读写用户设置  -->
        <default>
            <max_memory_usage>10000000000</max_memory_usage>
            <use_uncompressed_cache>0</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
        </default>

        <!-- 只写用户设置  -->
        <readonly>
            <max_memory_usage>10000000000</max_memory_usage>
            <use_uncompressed_cache>0</use_uncompressed_cache>
            <load_balancing>random</load_balancing>
            <readonly>1</readonly>
        </readonly>
    </profiles>

    <!-- 配额  -->
    <quotas>
        <!-- Name of quota. -->
        <default>
            <interval>
                <duration>3600</duration>
                <queries>0</queries>
                <errors>0</errors>
                <result_rows>0</result_rows>
                <read_rows>0</read_rows>
                <execution_time>0</execution_time>
            </interval>
        </default>
    </quotas>

    <users>
        <!-- 读写用户  -->
        <default>
            <password_sha256_hex>967f3bf355dddfabfca1c9f5cab39352b2ec1cd0b05f9e1e6b8f629705fe7d6e</password_sha256_hex>
            <networks incl="networks" replace="replace">
                <ip>::/0</ip>
            </networks>
            <profile>default</profile>
            <quota>default</quota>
        </default>

        <!-- 只读用户  -->
        <ck>
            <password_sha256_hex>967f3bf355dddfabfca1c9f5cab39352b2ec1cd0b05f9e1e6b8f629705fe7d6e</password_sha256_hex>
            <networks incl="networks" replace="replace">
                <ip>::/0</ip>
            </networks>
            <profile>readonly</profile>
            <quota>default</quota>
        </ck>
    </users>
</yandex>
```

##  ClickHouse其他重要配置

1.  /etc/clickhouse-server/config.xml 
2.  /etc/security/limits./clickhouse.conf

数据目录，临时目录位置，日志目录

+   /var/lib/clickhouse clickhouse soft nofile 262144
+   /var/lib/clickhouse/tmp/ clickhouse hard nofile 262144
+   /var/log/clickhouse-server

##  ClickHouse表引擎

参考资料：ClickHouse的表引擎：

https://www.jianshu.com/p/dbca0f5ededb?from=groupmessage

CK里面有非常多的引擎，这里只推荐3个：

MergeTree，是CK里最Advanced的引擎，性能超高，单机写入可以达到50w峰值，查询性能非常快，有兴趣看我其他文章

ReplicatedMergeTree，基于MergeTree，同时引入ZK，做了复制，下文会说

Distributed，分布式引擎，本身不存储数据，可认为就是一张View，如果写入，会把请求丢到集群里的节点（有算法控制），如果查询，会帮你做查询转发再聚合返回

##  ClickHouse数据复制

参考资料：ClickHouse的数据复制：https://www.jianshu.com/p/d1842290bd48

##  总结一下

基于`ReplicatedMergeTree + Zookeeper`的表复制

1.  使用的是复制表ReplicatedMergeTree+Zookeeper的协调一致性完成数据的复制和数据一致性
2.  数据相互复制且会进行数据验证，自动保证数据一致性
3.  建议3个节点做复制，设置至少保证2个节点收到数据才算成功，增强数据的一致性
4.  关于复制引擎，ClickHouse官方建议不搞特别大的集群，建议一个业务就跑一个集群，具体多少分片，自己衡量

基于`cluster + Distributed`的复制

1.  使用分布式表Distributed，集群的分片的副本的自动复制
2.  参数internal_replication要设置 `<internal_replication>false</internal_replication>` 写全部的分片，不建议：poor man replication
3.  仅仅对分布式表写入：并且在internal_replication=false的情况下，会写入分布式表对应的子表
4.  推荐使用的方式：

    -   写分布式表的情况下，设置 `<internal_replication>true</internal_replication>`，即只写一个shard里面的一个副本
    -   开启表级别的复制，无论哪一个副本被写入，副本数据都会被同步到其他副本节点


