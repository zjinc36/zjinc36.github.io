#   Druid-Kylin-Presto-Impala-SparkSQL-ES比较
+ date: 2020-09-14 11:07:27
+ description: Druid-Kylin-Presto-Impala-SparkSQL-ES比较
+ categories:
  - BigData
+ tags:
  - BigData
---
<!-- 
![](../images/2020/09/20200914110558.png)
 -->

|对比项目     |Druid     |Kylin|Presto |Impala |Spark SQL |ES   |
|----|----|----|----|----|----|----|
|亚秒级响应   |Y         |Y    |N      |N      |N         |N    |
|百亿数据集   |Y         |Y    |Y      |Y      |Y         |Y    |
|SQL支持      |N(开发中) |Y    |Y      |Y      |Y         |N    |
|离线         |Y         |Y    |Y      |Y      |Y         |Y    |
|实时         |Y         |Y    |N      |N      |N         |Y    |
|精确去重     |N         |Y    |Y      |Y      |Y         |N    |
|多表Join     |N         |Y    |Y      |Y      |Y         |N    |
|JDBC for BI  |N         |Y    |Y      |Y      |Y         |N    |
