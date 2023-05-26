# clickhouse里物化视图如何跟随源表更新数据

**创建两个源表，只有两个字段，通过id关联：**

以前在使用oracle等数据库的物化视图，只要源数据表有更新，视图就能跟随更新。但使用了[Clickhouse](https://so.csdn.net/so/search?q=Clickhouse&spm=1001.2101.3001.7020)的物化视图后，有多表关联时，官方文档上就没有标明如何触发物化视图的更新了。本文就是要解决这个问题。

**创建两个源表，只有两个字段，通过id关联：**

```sql
CREATE TABLE default.test0 (
`id` String,
 `name` String
) ENGINE = MergeTree PARTITION BY id ORDER BY id SETTINGS index_granularity = 8192

CREATE TABLE default.test00 (
`id` String,
 `name2` String
) ENGINE = MergeTree PARTITION BY id ORDER BY id SETTINGS index_granularity = 8192

```

```sql
insert into `default`.test0 values ('1','name1')

insert into `default`.test00 values ('1','name10')

select t0.id,name,name2 from `default`.test0 t0 join `default`.test00 t00 on t0.id=t00.id

```

当前用于建视图的as select语句是有结果的：

| id  | name | name2 |
| --- | --- | --- |
| 1   | name1 | name10 |
| **创建视图：** |     |     |

```sql
create  MATERIALIZED VIEW default.test_view  ENGINE = MergeTree PARTITION BY id ORDER BY id SETTINGS index_granularity = 8192
AS select t0.id,name,name2 from `default`.test0 t0 join `default`.test00 t00 on t0.id=t00.id

select * from default.test_view

```

| id  | name | name2 |
| --- | --- | --- |

–插数据再查

```sql
insert into `default`.test0 values ('2','name2')

insert into `default`.test00 values ('2','name20')

select * from default.test_view

```

新增数据没有同步到物化视图：

| id  | name | name2 |
| --- | --- | --- |

只针对单表创建一个物化视图，不使用join：

```sql
create  MATERIALIZED VIEW default.test_view0  ENGINE = MergeTree PARTITION BY id ORDER BY id SETTINGS index_granularity = 8192
AS select  id,name FROM `default`.test0 

select * from default.test_view

insert into `default`.test0 values ('5','name5')

select * from default.test_view0

```

结果物化视图数据同步了：

| id  | name |
| --- | --- |
| 5   | name5 |

那么，基于单表建的物化视图与带关联的物化视图有何区别？这里是问题关键所在。

**后来，在clickhouse上提问，得到了回复：**

> Materialiezed view 将在最左边的表插入后更新。

**下面进行最左原则测试：**
视图的查询语句是：

```sql
AS select t0.id,name,name2 from 
`default`.test0 t0
  join 
   `default`.test00 t00 on t0.id=t00.id

```

按从右表到左表插入数据：

```sql
insert into `default`.test00 values ('1','name10')
insert into `default`.test0 values ('1','name1')

```

查询一下物化视图：

```sql
select * from default.test_view

```

新插入数据进入视图了：

| id  | name | name2 |
| --- | --- | --- |
| 1   | name1 | name10 |

然后换顺序插一次：

```sql
insert into `default`.test0 values ('2','name2')
insert into `default`.test00 values ('2','name20')

```

再查询一下物化视图：

```sql
select * from default.test_view

```

新插到源表的数据没有进入视图：

| id  | name | name2 |
| --- | --- | --- |
| 1   | name1 | name10 |
