#   Clickhouse与kudu,kylin,druid的区别和使用场景

---

#   OLAP数据库分类
+   OLAP到现在也都是两个套路
    -   一个用空间换时间，就是MOLAP（多维在线分析）
    -   一个充分利用所有资源快速计算, 就是ROLAP（关系型在线分析）
    -   当然还有一个混合的，那个不管

+   OLAP数据库
    -   Kylin和Druid都是MOLAP的典范
    -   ClickHouse则是ROLAP的佼佼者
    -   kudu是一个支持OLAP的大数据存储引擎，也能用来做OLAP

#   如何选择
1.  如果你的业务部门要求高并发高性能，那就可以用Kylin和Druid，这两个都是预计算的套路，你给他设定好分析路线，kylin建CUBE，Druid做各种group by的计算，业务部门分析的时候就等于是直接查询已经计算好的结果。速度和并发量的表现都非常棒。缺点是吃存储，分析路径比较死，加一个维度得改模型。
2.  如果你的业务部门人不多，就内部用，但是比较挑剔，要非常高的自由度，那就可以用ClickHouse。这个你建各种表就好了。业务部门基于数据关系自己选择，CK现算，给答案。这个单表查询效率超高，join的话不太满意。而且因为都是现算的，并发量上不去。最关键的是CK所在的服务器基本干不了别的，查几条数据都有可能吃掉50%以上的CPU。

#   案例
这个文章里有各大厂使用ClickHouse的案例，可以了解一下：
https://mp.weixin.qq.com/s?__biz=MzIwNjM0MTc0Ng==&mid=2247485372&idx=1&sn=20359e5a696144ace29f1b705ca69f97&chksm=972254a1a055ddb7944bfacd7927df6188276c8668411b538ad1ea60ea54c1fd0bb6af702b39#rd

#   来源
+   https://www.zhihu.com/question/303991599/answer/1555185339
